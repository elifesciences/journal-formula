api-dummy-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy.conf
        - source: salt://journal/config/etc-nginx-sites-enabled-api-dummy.conf
        - require:
            - api-dummy-composer-install
            - journal-nginx-vhost-local-demo
        - listen_in:
            - service: nginx-server-service
            - service: php-fpm
