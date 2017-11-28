npm-critical-css-build-dependencies:
    pkg.installed:
        - pkgs:
            - libgconf-2-4
            - libnss3
            - libxss1

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
            - npm-critical-css-build-dependencies
            - php-fpm
        - require_in:
            - cmd: maintenance-mode-end
