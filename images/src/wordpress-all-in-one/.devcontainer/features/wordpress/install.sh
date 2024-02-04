#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Downloading WordPress...'

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    WEB_USER="${CONTAINER_USER:-www-data}"
else
    WEB_USER="${_REMOTE_USER}"
fi

install -d -m 0755 -o root -g root /etc/wp-cli /usr/share/wordpress
install -d -o "${WEB_USER}" -g "${WEB_USER}" -m 0755 /wp
su-exec "${WEB_USER}:${WEB_USER}" wp core download --path=/wp --version="latest"
cp -a wp/* /wp && chown -R "${WEB_USER}:${WEB_USER}" /wp/* && chmod -R 0755 /wp/* && find /wp -type f -exec chmod 0644 {} \;
install -m 0644 -o root -g root wp-cli.yml /etc/wp-cli

install -m 0755 -o root -g root setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
install -m 0755 -o root -g root wordpress-post-create.sh /usr/local/bin/wordpress-post-create.sh
install -d -D -m 0755 -o root -g root /var/lib/wordpress/postinstall.d

echo 'Done!'
