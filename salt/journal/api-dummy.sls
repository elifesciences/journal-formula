api-dummy-nginx-vhost:
    file.managed:
        - name: /etc/nginx/sites-enabled/api-dummy.conf
        - source: salt://journal/config/etc-nginx-sites-enabled-api-dummy.conf
        - listen_in:
            - service: nginx-server-service
