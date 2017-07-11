#!/bin/bash
set -e

redis_present () {
    test -e /etc/init.d/redis-server
}

if redis_present; then
    sudo /etc/init.d/redis-server stop
fi
retry node_modules/.bin/gulp 3
if redis_present; then
    sudo /etc/init.d/redis-server start
fi
# avoid exit code specified from the if failure
exit 0
