git.latest:
    - user: {{ pillar.sys.deploy_user.username }}
    - name: git@github.com:elifesciences/journal.git
    - rev: {{ salt['elife.rev']() }}
    - branch: {{ salt['elife.branch']() }}
    - target: /srv/journal/
    - force_fetch: True
    - force_checkout: True
    - force_reset: True
