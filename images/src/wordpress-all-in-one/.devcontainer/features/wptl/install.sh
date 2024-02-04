#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    WEB_USER="${CONTAINER_USER:-www-data}"
else
    WEB_USER="${_REMOTE_USER}"
fi

apk add --no-cache subversion
install -m 0755 -o root -g root setup-wptl.sh /usr/local/bin/setup-wptl
install -m 0755 -o root -g root use-wptl.sh /usr/local/bin/use-wptl
install -d -D -m 0755 -o "${WEB_USER}" -g "${WEB_USER}" /usr/src/wordpress

su-exec "${WEB_USER}:${WEB_USER}" setup-wptl latest

echo 'Done!'
