#!/usr/bin/env sh
set -eu

envsubst '${FONTS_HOST}' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

exec "$@"
