#!/usr/bin/env bash
. /opt/smoke.sh/smoke.sh
set -e

docker-wait-healthy journal_fpm_1

hostname="${1:-$(hostname)}"
port="${2:-80}"

# retrieve manifest from container, if present
docker cp journal_fpm_1:/srv/journal/build/rev-manifest.json .

function from_manifest {
    jq -r ".[\"${1}\"]" < rev-manifest.json
}

# smoke.sh can't run with `set -e`
set +e
smoke_url_ok "$hostname:$port/favicon.ico"
smoke_url_ok "$hostname:$port/$(from_manifest assets/favicons/manifest.json)"
smoke_url_ok "$hostname:$port/$(from_manifest assets/patterns/css/all.css)"
smoke_url_ok "$hostname:$port/$(from_manifest assets/images/banners/magazine-1114x336@1.jpg)"
smoke_url_ok "$hostname:$port/ping"
    smoke_assert_body "pong"

set -e
retry "./status_test.sh $hostname $port" 3 5
set +e
smoke_url_ok "$hostname:$port/"

smoke_report
