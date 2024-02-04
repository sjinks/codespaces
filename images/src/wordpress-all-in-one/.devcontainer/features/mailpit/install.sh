#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing Mailpit...'

ARCH="$(arch)"
LATEST=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/axllent/mailpit/releases/latest -o /dev/null | sed -e 's|.*/||')
if [ "${ARCH}" = "arm64" ] || [ "${ARCH}" = "aarch64" ]; then
    ARCH="arm64"
elif [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then
    ARCH="amd64"
else
    echo "(!) Unsupported architecture: ${ARCH}"
    exit 1
fi

mkdir -p /tmp/mailpit
( \
    cd /tmp/mailpit && \
    wget -q "https://github.com/axllent/mailpit/releases/download/${LATEST}/mailpit-linux-${ARCH}.tar.gz" -O - | tar -xz && \
    install -m 0755 -o root -g root mailpit /usr/local/bin/mailpit && \
    cd .. && \
    rm -rf /tmp/mailpit \
)

: "${PHP_INI_DIR:=/etc/php}":
if [ -d "${PHP_INI_DIR}/conf.d" ]; then
    install -m 0644 php-mailpit.ini "${PHP_INI_DIR}/conf.d/mailpit.ini"
fi

install -D -m 0755 -o root -g root service-run /etc/sv/mailpit/run
install -d -m 0755 -o root -g root /etc/service
ln -sf /etc/sv/mailpit /etc/service/mailpit

echo 'Done!'
