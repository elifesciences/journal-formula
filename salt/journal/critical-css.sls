npm-critical-css-build-dependencies:
    pkg.installed:
        - pkgs:
            # from https://github.com/GoogleChrome/puppeteer/blob/master/docs/troubleshooting.md
            - gconf-service
            - libasound2
            - libatk1.0-0
            - libc6
            - libcairo2
            - libcups2
            - libdbus-1-3
            - libexpat1
            - libfontconfig1
            - libgcc1
            - libgconf-2-4
            - libgdk-pixbuf2.0-0
            - libglib2.0-0
            - libgtk-3-0
            - libnspr4
            - libpango-1.0-0
            - libpangocairo-1.0-0
            - libstdc++6
            - libx11-6
            - libx11-xcb1
            - libxcb1
            - libxcomposite1
            - libxcursor1
            - libxdamage1
            - libxext6
            - libxfixes3
            - libxi6
            - libxrandr2
            - libxrender1
            - libxss1
            - libxtst6
            - ca-certificates
            - fonts-liberation
            - libappindicator1
            - libnss3
            - lsb-release
            - xdg-utils
            - wget

generate-critical-css:
    cmd.run:
        - name: |
            node_modules/.bin/gulp critical-css:generate
            ./check_critical_css.sh
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
