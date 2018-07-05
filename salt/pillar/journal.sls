journal:
    api_url: https://prod--cdn-gateway.elifesciences.org/
    api_url_public: '%api_url%'
    api_key: key_for_authorizing_api_requests
    side_by_side_view_url: https://lens.elifesciences.org/
    observer_url: https://observer.elifesciences.org/
    default_host: null

    gtm_id: null
    cookie_consent: false

    secret: ThisTokenIsNotSoSecretChangeIt

    session_name: journal

    web_users: {}

    redis_cache: redis://localhost
    redis_sessions: redis://localhost

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

    hypothesis_api: https://hypothes.is/api/
    hypothesis_authority: some-authority
    hypothesis_client_id: some-id
    hypothesis_client_secret: ThisIsASecret

    cache:
        max_age: 300
        stale_while_revalidate: 300
        stale_if_error: 86400

    subject_rewrites: []

api_dummy:
    standalone: False
    pinned_revision_file: /srv/journal/api-dummy.sha1
