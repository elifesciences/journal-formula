journal:
    api_url: https://api.elifesciences.org/
    api_url_public: '%api_url%'
    api_key: key_for_authorizing_api_requests
    side_by_side_view_url: https://lens.elifesciences.org/
    observer_url: https://prod--observer.elifesciences.org/

    secret: ThisTokenIsNotSoSecretChangeIt

    session_name: journal

    web_users: {}

    mailer:
        host: localhost
        port: 25
        username: anonymous
        password: ""
        encryption: "null"

    status_checks:
        Articles: articles
