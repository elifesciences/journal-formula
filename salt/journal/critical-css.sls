journal-local-demo-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/journal-local-demo.conf
        - source: salt://journal/config/etc-nginx-sites-enabled-journal-local-demo.conf
        - template: jinja
        - require:
            - nginx-config
        - require_in:
            - cmd: maintenance-mode-start

api-dummy-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy.conf
        - source: salt://journal/config/etc-nginx-sites-enabled-api-dummy.conf
        - require:
            - nginx-config
        - require_in:
            - cmd: maintenance-mode-start

api-dummy-journal-repository:
    cmd.run:
        - name: echo "journal-repository is ready for api-dummy-repository"
        - require:
            - journal-repository
        - require_in:
            - cmd: api-dummy-repository

journal-local-demo-separate-folder:
    file.directory:
        - name: /srv/journal-local-demo
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}

    cmd.run:
        - name: |
            rsync -a --exclude='.git' --exclude 'app/config/parameters.yml' --include 'build/rev-manifest.json' --include 'build/critical-css/.gitkeep' --exclude 'build/*' --exclude 'node_modules' --include 'var/.gitkeep' --exclude 'var/*' --delete /srv/journal/ /srv/journal-local-demo
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - file: journal-local-demo-separate-folder
            - running-gulp

journal-local-demo-parameters:
    file.managed:
        - name: /srv/journal-local-demo/app/config/parameters.yml
        - source: salt://journal/config/srv-journal-local-demo-app-config-parameters.yml
        - template: jinja
        - user: {{ pillar.elife.deploy_user.username }}
        - group: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-local-demo-separate-folder

journal-local-demo-cache-clean:
    cmd.run:
        - name: bin/console cache:clear --env=demo
        - cwd: /srv/journal-local-demo
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - journal-local-demo-parameters

generate-critical-css:
    cmd.run:
        - name: node_modules/.bin/gulp critical-css:generate
        - cwd: /srv/journal
        - user: {{ pillar.elife.deploy_user.username }}
        - require:
            - api-dummy-composer-install
            - api-dummy-nginx-vhost
            - journal-local-demo-cache-clean
            - journal-local-demo-nginx-vhost
            - php-fpm
        - require_in:
            - cmd: maintenance-mode-end
