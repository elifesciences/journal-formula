{% set oscodename = salt['grains.get']('oscodename') %}

# https://launchpad.net/ettercap/+packages
curl-7-36-ppa:
    # this PPA contains nightly unstable builds of ettercap,
    # but the curl contained there is stable
    pkgrepo.managed:
        - humanname:  ettercap stable backports 
        - name: deb http://ppa.launchpad.net/costamagnagianfranco/ettercap-stable-backports/ubuntu {{ oscodename }} main
        - dist: {{ oscodename }}
        - file: /etc/apt/sources.list.d/ettercap-stable-backports.list
        - keyserver: keyserver.ubuntu.com

curl-7-36-packages:
    pkg.installed:
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
