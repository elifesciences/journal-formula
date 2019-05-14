maintenance-mode-start:
    cmd.run:
        - name: |
            rm -f /etc/nginx/sites-enabled/journal.conf
            /etc/init.d/nginx reload
        - require:
            - nginx-server-service

journal-repository:
    builder.git_latest:
        - name: git@github.com:elifesciences/journal.git
        - identity: {{ pillar.elife.projects_builder.key or '' }}
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /srv/journal/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - fetch_pull_requests: True
        - require:
            - cmd: composer
            - maintenance-mode-start

    file.directory:
        - name: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group
        - require:
            - builder: journal-repository

config-file:
    file.managed:
        - name: /srv/journal/app/config/parameters.yml
        - source: salt://journal/config/srv-journal-app-config-parameters.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: journal-repository

# files and directories must be readable and writable by both elife and www-data
# they are both in the www-data group, but the g+s flag makes sure that
# new files and directories created inside have the www-data group
var-directory:
    file.directory:
        - name: /srv/journal/var
        - user: {{ pillar.elife.webserver.username }}
        - group: {{ pillar.elife.webserver.username }}
        - dir_mode: 775
        - file_mode: 660
        - recurse:
            - user
            - group
            - mode
        - require:
            - builder: journal-repository

    cmd.run:
        - name: chmod -R g+s /srv/journal/var
        - require:
            - file: var-directory

npm-build-dependencies:
    pkg.installed:
        - pkgs:
            - make
            - g++
            - libjpeg-turbo-progs
            - optipng

journal-npm-install:
    cmd.run:
        - name: npm install
        - cwd: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-repository
            - npm-build-dependencies

journal-node-modules-manual-install:
    cmd.run:
        - name: |
            node node_modules/mozjpeg/lib/install.js
            node node_modules/optipng-bin/lib/install.js
        - cwd: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-npm-install

composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo', 'end2end', 'continuumtest', 'preview', 'continuumtestpreview'] %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative --no-dev
        {% elif pillar.elife.env != 'dev' %}
        - name: composer --no-interaction install --no-suggest --classmap-authoritative
        {% else %}
        - name: composer --no-interaction install --no-suggest
        {% endif %}
        - cwd: /srv/journal/
        - user: {{ pillar.elife.deploy_user.username }}
        - env:
            - COMPOSER_DISCARD_CHANGES: 'true'
        - require:
            - file: config-file

journal-cache-clean:
    cmd.run:
        - name: rm -rf var/cache/
        - cwd: /srv/journal/
        - require:
            - var-directory

journal-cache-warmup:
    cmd.run:
        - name: bin/console cache:warmup
        - cwd: /srv/journal/
        - user: {{ pillar.elife.webserver.username }}
        - env:
            - APP_ENV: {{ pillar.elife.env }}
        - require:
            - composer-install
            - journal-cache-clean

journal-assets-install:
    cmd.run:
        - name: bin/console assets:install --symlink
        - cwd: /srv/journal/
        - user: {{ pillar.elife.deploy_user.username }}
        - env:
            - APP_ENV: {{ pillar.elife.env }}
        - require:
            - journal-cache-warmup

journal-nginx-redirect-existing-paths:
    file.managed:
        - name: /etc/nginx/traits.d/redirect-existing-paths.conf
        - source: salt://journal/config/etc-nginx-traits.d-redirect-existing-paths.conf
        - template: jinja
        - require:
            - nginx-config
        - listen_in:
            - service: nginx-server-service

journal-nginx-robots:
    file.managed:
        - name: /etc/nginx/traits.d/robots.conf
        - source: salt://journal/config/etc-nginx-traits.d-robots.conf
        - template: jinja
        - require:
            - nginx-config
        - listen_in:
            - service: nginx-server-service

journal-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-available/journal.conf
        - source: salt://journal/config/etc-nginx-sites-available-journal.conf
        - template: jinja
        - require:
            - nginx-config
            - nginx-error-pages
            - journal-nginx-redirect-existing-paths
            - journal-nginx-robots

running-gulp:
    {% if pillar.elife.env in ['end2end', 'prod'] %}
    # using Elasticache so no local Redis is present
    cmd.run:
        - name: retry node_modules/.bin/gulp 3
    {% else %}
    cmd.script:
        - name: retrying-gulp
        - source: salt://journal/scripts/retrying-gulp-without-redis.sh
    {% endif %}
        - cwd: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-npm-install
            - journal-node-modules-manual-install
            - composer-install

maintenance-mode-end:
    cmd.run:
        - name: |
            ln -s /etc/nginx/sites-available/journal.conf /etc/nginx/sites-enabled/journal.conf
            /etc/init.d/nginx reload
        - require:
            - journal-nginx-vhost
            - running-gulp

maintenance-mode-check-nginx-stays-up:
    cmd.run:
        - name: sleep 2 && /etc/init.d/nginx status
        - require:
            - maintenance-mode-end

{% for title, user in pillar.journal.web_users.items() %}
journal-nginx-authentication-{{ title }}:
    webutil.user_exists:
        - name: {{ user.username }}
        - password: {{ user.password }}
        - htpasswd_file: /etc/nginx/journal.htpasswd
        - force: True
        - require:
            - journal-nginx-vhost
{% endfor %}


syslog-ng-for-journal-logs:
    file.managed:
        - name: /etc/syslog-ng/conf.d/journal.conf
        - source: salt://journal/config/etc-syslog-ng-conf.d-journal.conf
        - template: jinja
        - require:
            - pkg: syslog-ng
            - composer-install
        - listen_in:
            - service: syslog-ng

logrotate-for-journal-logs:
    file.managed:
        - name: /etc/logrotate.d/journal
        - source: salt://journal/config/etc-logrotate.d-journal
