journal:
    api_url: https://prod--cdn-gateway.elifesciences.org/
    api_url_search_page: '%api_url%'
    api_url_public: '%api_url%'
    api_key: public
    side_by_side_view_url: https://lens.elifesciences.org/
    observer_url: https://observer.elifesciences.org/
    # no trailing slashes. leave empty to prevent adding redirect rules
    preprint_url: https://staging--epp.elifesciences.org
    pubpub_url: https://elife-container.pubpub.org
    # no trailing slashes. leave empty to prevent adding redirect rules
    about_url:
    resources_url:
    media_policy_url:
    community_url:
    privacy_notice_url:
    cookie_declaration_url:
    learning_resources_url:
    default_host: null

    submit_url: https://submit.elifesciences.org/

    # This parameter, if truthy, redirects /submit to the given value.
    # This is different from submit_url and submit_url_redirects, in that these values exist for journal code
    submit_redirect_url:

    crm_api_key: ~
    crm_api_site_key: ~

    google_api_client:
        client_id: some-id
        client_secret: ThisIsASecret
        refresh_token: Refreshtoken
        optout_unsubscribe_spreadsheet_id: spreadsheet-id

    gtm_id: null
    cb_id: null

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

    #fixed_response_paths:
    #    404:
    #        - /profiles/foo

api_dummy:
    standalone: False
    pinned_revision_file: /srv/journal/api-dummy.sha1
