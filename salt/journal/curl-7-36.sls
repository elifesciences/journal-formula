curl-7-36-ppa:
    # this PPA contains nightly unstable builds of ettercap,
    # but the curl contained there is stable
    pkgrepo.managed:
        - humanname:  ettercap stable backports 
        - name: deb http://ppa.launchpad.net/costamagnagianfranco/ettercap-stable-backports/ubuntu trusty main
        - dist: trusty
        - file: /etc/apt/sources.list.d/ettercap-stable-backports.list
        - keyid: 3C2A1859
        - keyserver: keyserver.ubuntu.com

curl-7-36-packages:
    pkg.latest:
        - pkgs:
            - curl
            - libcurl3
            - libcurl3-gnutls
        - refresh: True
        - require:
            - pkgrepo: curl-7-36-ppa
        # warning: assumes php-fpm is around
        - watch_in:
            - service: php-fpm
