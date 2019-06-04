maintenance-mode-start:
    cmd.run:
        - name: |
            rm -f /etc/nginx/sites-enabled/journal.conf
            /etc/init.d/nginx reload
        - require:
            - nginx-server-service

journal-folder:
    file.directory:
        - name: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - recurse:
            - user
            - group

journal-folder-old-git-repository:
    file.absent:
        - name: /srv/journal/.git
        - require:
            - journal-folder

journal-docker-compose-env:
    file.managed:
        - name: /srv/journal/.env
        - source: salt://journal/config/srv-journal-.env
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - journal-folder

journal-docker-compose-containers-env:
    file.managed:
        - name: /srv/journal/containers.env
        - source: salt://journal/config/srv-journal-containers.env
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - journal-folder

journal-dockerfile-web:
    file.managed:
        - name: /srv/journal/Dockerfile.web
        - source: salt://journal/config/srv-journal-Dockerfile.web
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - journal-folder

config-file:
    file.managed:
        - name: /srv/journal/parameters.yml
        # TODO: rename
        - source: salt://journal/config/srv-journal-parameters.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-folder

assets-nginx-configuration:
    file.managed:
        - name: /srv/journal/nginx-assets.conf
        - source: salt://journal/config/srv-journal-nginx-assets.conf
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-folder

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
            - journal-folder

    cmd.run:
        - name: chmod -R g+s /srv/journal/var
        - require:
            - file: var-directory

# deprecated, remove when no longer necessary
stop-existing-services:
    cmd.run:
        - name: |
            set -e
            # if not stopped, may conflict with port 9000 forwarded from the host to the container
            stop php7.0-fpm || true
            rm -f /etc/nginx/sites-enabled/api-dummy.conf
            rm -f /etc/nginx/sites-enabled/journal-local-demo.conf
        - require_in:
            - cmd: journal-docker-compose

journal-docker-compose:
    file.managed:
        - name: /srv/journal/docker-compose.yml
        - source: salt://journal/config/srv-journal-docker-compose.yml
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - template: jinja
        - require:
            - journal-docker-compose-env
            - journal-docker-compose-containers-env
            - journal-dockerfile-web

    cmd.run:
        - name: |
            set -e
            rm -f docker-compose.override.yml
            docker-compose --no-ansi pull fpm
            docker-compose --no-ansi build
            docker-compose --no-ansi up --detach --force-recreate
        - cwd: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: journal-docker-compose

journal-cache-warmup:
    cmd.run:
        - name: docker-compose exec -T fpm bin/console cache:warmup
        - cwd: /srv/journal/
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-docker-compose

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

maintenance-mode-end:
    cmd.run:
        - name: |
            set -e
            ln -s /etc/nginx/sites-available/journal.conf /etc/nginx/sites-enabled/journal.conf
            /etc/init.d/nginx reload
        - require:
            - journal-nginx-vhost

maintenance-mode-check-nginx-stays-up:
    cmd.run:
        - name: sleep 2 && /etc/init.d/nginx status
        - require:
            - maintenance-mode-end

status-test:
    file.managed:
        - name: /srv/journal/status_test.sh
        - source: salt://journal/config/srv-journal-status_test.sh
        - mode: 755
        - require:
            - journal-folder

smoke-tests:
    file.managed:
        - name: /srv/journal/smoke_tests.sh
        - source: salt://journal/config/srv-journal-smoke_tests.sh
        - mode: 755
        - require:
            - journal-folder
            - status-test

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
        - listen_in:
            - service: syslog-ng

logrotate-for-journal-logs:
    file.managed:
        - name: /etc/logrotate.d/journal
        - source: salt://journal/config/etc-logrotate.d-journal
