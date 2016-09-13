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
            - cmd: php-composer-1.0
            - cmd: php-puli-latest

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
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.webserver.username }}
        - dir_mode: 775
        - file_mode: 664
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

web-assets-symlink-cleaning:
    cmd.run:
        - name: rm -f web/assets
        - cwd: /srv/journal/

composer-install:
    cmd.run:
        {% if pillar.elife.env in ['prod', 'demo', 'end2end'] %}
        - name: composer1.0 --no-interaction install --classmap-authoritative --no-dev
        {% elif pillar.elife.env in ['ci'] %}
        - name: composer1.0 --no-interaction install --classmap-authoritative
        {% else %}
        - name: composer1.0 --no-interaction install
        {% endif %}
        - cwd: /srv/journal/
        - user: {{ pillar.elife.deploy_user.username }}
        # to correctly write into var/
        - umask: 002
        - env:
            - SYMFONY_ENV: {{ pillar.elife.env }}
        - require:
            - file: config-file
            - cmd: web-assets-symlink-cleaning
            - cmd: var-directory

puli-publish-install:
    cmd.run:
        - name: puli publish --install
        - cwd: /srv/journal/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - cmd: composer-install

journal-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/website.conf
        - source: salt://journal/config/etc-nginx-sites-enabled-journal.conf
        - template: jinja
        - require:
            - nginx-config
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm

{% if pillar.elife.env in ['ci', 'dev'] %}
journal-behat:
    file.managed:
        - name: /srv/journal/behat.yml
        - source: salt://journal/config/srv-journal-behat.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: journal-repository
{% endif %}
