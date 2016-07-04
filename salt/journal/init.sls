php-composer-1.0:
   cmd.run:
        - name: |
            cp composer composer1.0
            composer1.0 self-update 1.0.3
        - cwd: /usr/local/bin/
        - require:
            - cmd: install-composer
        - unless:
            - which composer1.0

php-puli-latest:
   cmd.run:
        - name: |
            curl https://puli.io/installer | php
            mv puli.phar puli
        - cwd: /usr/local/bin/
        - unless:
            - which puli

journal-repository:

    git.latest:
        - identity: {{ pillar.elife.deploy_user.key }}
        - name: git@github.com:elifesciences/journal.git
        - rev: {{ salt['elife.rev']() }}
        - branch: {{ salt['elife.branch']() }}
        - target: /srv/journal/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
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
            - git: journal-repository

config-file:
    file.managed:
        - name: /srv/journal/app/config/parameters.yml
        - source: salt://journal/config/srv-journal-app-config-parameters.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require: 
            - git: journal-repository

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
            - git: journal-repository

    cmd.run:
        - name: chmod g+s /srv/journal/var
        - require:
            - file: var-directory

composer-install:
    cmd.run:
        - name: composer1.0 install
        - cwd: /srv/journal/
        - user: {{ pillar.elife.deploy_user.username }}
        # to correctly writing into var/
        - umask: 002
        - require:
            - file: config-file
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
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm
