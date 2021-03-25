journal:
    api_url: https://prod--cdn-gateway.elifesciences.org/
    api_url_public: '%api_url%'
    api_key: public
    side_by_side_view_url: https://lens.elifesciences.org/
    observer_url: https://observer.elifesciences.org/
    default_host: null

    submit_url: https://submit.elifesciences.org/

    gtm_id: null
    cookie_consent: false

    secret: ThisTokenIsNotSoSecretChangeIt

    session_name: journal

    web_users: {}

    robots:
        - |
            User-Agent: *
            Disallow: $robots_disallow
            Disallow: /download/
        - | 
            User-agent: Amazonbot
            Disallow: /search/
        - | 
            User-agent: turnitinbot
            Disallow: /search/
        - | 
            User-agent: bingbot
            Disallow: /search/

    redis_cache: redis://redis
    redis_sessions: redis://redis

    mailer:
        # absolute hostname in real environments, reachable from any container
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

    submission_client_id: some-id
    submission_client_secret: ThisIsASecret

    cache_control: private, no-cache, no-store, must-revalidate

    {% import_yaml "era-articles.yaml" as era_articles %}
    era_articles: {{ era_articles|yaml }}
    rds_articles: {{ era_articles|yaml }}

    dismissible_info_bars:
        aging:
            id: aging-special-issue
            text: '<a href="https://elifesciences.org/inside-elife/4f706531/special-issue-call-for-papers-in-aging-geroscience-and-longevity">Read the call for papers</a> for the eLife Special Issue on Aging, Geroscience and Longevity'
            article_ids:
                - '26231'

    subject_rewrites: []

    calls_to_action: []

api_dummy:
    standalone: False
    pinned_revision_file: /srv/journal/api-dummy.sha1
