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
    file.directory:
        - name: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - cmd: php-composer-1.0
            - cmd: php-puli-latest

    git.latest:
        - user: {{ pillar.elife.deploy_user.username }}
        - name: git@github.com:elifesciences/journal.git
        - rev: jenkinsfile #HEAD
        - branch: jenkinsfile #{{ salt['elife.branch']() }}
        - target: /srv/journal/
        - force_fetch: True
        - force_checkout: True
        - force_reset: True
        - require:
            - file: journal-repository

config-file:
    file.managed:
        - name: /srv/journal/app/config/parameters.yml
        - source: salt://journal/config/srv-journal-app-config-parameters.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - require: 
            - git: journal-repository

composer-install:
    cmd.run:
        - name: composer1.0 install
        - cwd: /srv/journal/
        - require:
            - file: config-file
