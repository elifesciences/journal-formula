journal:
    api_url: https://prod--cdn-gateway.elifesciences.org/
    api_url_public: '%api_url%'
    api_key: key_for_authorizing_api_requests
    side_by_side_view_url: https://lens.elifesciences.org/
    observer_url: https://observer.elifesciences.org/
    default_host: null

    submit_url: https://submit.elifesciences.org/

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

    #subdomain_redirects:
    #    subdomain1: /bar # subdomain1.domain.tld/foo redirected to domain.tld/bar
    #    subdomain2:      # subdomain2.domain.tld/foo redirected to domain.tld/foo

    hypothesis_api: https://hypothes.is/api/
    hypothesis_authority: some-authority
    hypothesis_client_id: some-id
    hypothesis_client_secret: ThisIsASecret

    xpub_secret: ThisIsASecret

    cache_control: private, no-cache, no-store, must-revalidate

    subject_rewrites: []

    feature_digest_channel: true
    feature_xpub: false

api_dummy:
    standalone: False
    pinned_revision_file: /srv/journal/api-dummy.sha1
