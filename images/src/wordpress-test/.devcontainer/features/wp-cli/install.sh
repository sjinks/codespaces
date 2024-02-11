#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing wp-cli...'
wget -q "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar" -O /usr/local/bin/wp
chmod 0755 /usr/local/bin/wp
echo 'Done!'
