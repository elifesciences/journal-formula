journal:
    api_url: https://prod--cdn-gateway.elifesciences.org/
    api_url_public: '%api_url%'
    api_key: key_for_authorizing_api_requests
    side_by_side_view_url: https://lens.elifesciences.org/
    observer_url: https://observer.elifesciences.org/
    default_host: null

    gtm_id: null
    disqus_domain: elifesciences-staging

    secret: ThisTokenIsNotSoSecretChangeIt

    session_name: journal

    web_users: {}

    redis: redis://localhost

    mailer:
        host: localhost
        port: 25
        username: anonymous
        password: ""
        encryption: "null"

    status_checks:
        Articles: articles

    oauth2_client_id: some-id
    oauth2_client_secret: ThisIsASecret

    critical_css: False

    tenon:
        api_key: 

    # requests for sub.domain.tld are redirected to domain.tld/whatever
    #subdomain_redirects:
    #    subdomain: /whatever

api_dummy:
    standalone: False
    pinned_revision_file: /srv/journal/api-dummy.sha1
