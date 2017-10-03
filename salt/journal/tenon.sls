tenon-api-key:
    cmd.run:
        - name: |
            echo 'export TENON_API_KEY={{ pillar.journal.tenon.api_key }}' > /etc/profile.d/tenon-api-key.sh
