#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing MariaDB...'

apk add --no-cache mariadb-client mariadb

install -D -m 0755 -o root -g root service-run /etc/sv/mariadb/run
install -d -m 0755 -o root -g root /etc/service
ln -sf /etc/sv/mariadb /etc/service/mariadb

/usr/bin/mysql_install_db --auth-root-authentication-method=normal --skip-test-db --user=mysql --datadir=/var/lib/mysql

echo 'Done!'
