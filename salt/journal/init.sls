git.latest:
    - user: {{ pillar.elife.deploy_user.username }}
    - name: git@github.com:elifesciences/journal.git
    - rev: HEAD
    - branch: {{ salt['elife.branch']() }}
    - target: /srv/journal/
    - force_fetch: True
    - force_checkout: True
    - force_reset: True
