#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo "(*) Installing PHP..."

apk add --no-cache \
    icu-data-full ghostscript \
    php83 php83-fpm php83-pear \
    php83-pecl-apcu \
    php83-bcmath \
    php83-calendar \
    php83-ctype \
    php83-curl \
    php83-dom \
    php83-exif \
    php83-fileinfo \
    php83-ftp \
    php83-gd \
    php83-gmp \
    php83-iconv \
    php83-intl \
    php83-json \
    php83-mbstring \
    php83-pecl-igbinary \
    php83-pecl-imagick \
    php83-pecl-memcache \
    php83-pecl-memcached \
    php83-mysqli \
    php83-mysqlnd \
    php83-opcache \
    php83-openssl \
    php83-pcntl \
    php83-pdo \
    php83-pdo_sqlite \
    php83-phar \
    php83-posix \
    php83-session \
    php83-shmop \
    php83-simplexml \
    php83-soap \
    php83-sockets \
    php83-sodium \
    php83-sqlite3 \
    php83-sysvsem \
    php83-sysvshm \
    php83-tokenizer \
    php83-xml \
    php83-xmlreader \
    php83-xmlwriter \
    php83-zip \
    php83-pecl-pcov

rm -f /usr/bin/phar /usr/bin/phar.phar
[ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm
[ ! -f /usr/bin/php ] && ln -s /usr/bin/php83 /usr/bin/php
[ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl83 /usr/bin/pecl
[ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear83 /usr/bin/pear
[ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev83 /usr/bin/peardev
[ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar83 /usr/bin/phar
[ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar83 /usr/bin/phar.phar

PHP_INI_DIR=/etc/php83
echo "export PHP_INI_DIR=${PHP_INI_DIR}" > /etc/profile.d/php_ini_dir.sh

getent group www-data > /dev/null || addgroup -g 82 -S www-data
getent passwd www-data > /dev/null || adduser -u 82 -D -S -G www-data -H www-data

pecl update-channels
rm -rf /tmp/pear ~/.pearrc

install -m 0644 php.ini "${PHP_INI_DIR}/php.ini"
if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    PHP_USER="${CONTAINER_USER:-www-data}"
else
    PHP_USER="${_REMOTE_USER}"
fi

export PHP_USER
# shellcheck disable=SC2016
envsubst '$PHP_USER' < www.conf.tpl > "${PHP_INI_DIR}/php-fpm.d/www.conf"
install -d -m 0750 -o "${PHP_USER}" -g adm /var/log/php-fpm
install -m 0644 -o root -g root docker.conf zz-docker.conf "${PHP_INI_DIR}/php-fpm.d/"
install -D -m 0755 -o root -g root service-run /etc/sv/php-fpm/run
install -d -m 0755 -o root -g root /etc/service
ln -sf /etc/sv/php-fpm /etc/service/php-fpm

wget -q https://getcomposer.org/installer -O composer-setup.php
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('sha384', 'composer-setup.php') === '${HASH}') { echo 'Installer verified', PHP_EOL; } else { echo 'Installer corrupt', PHP_EOL; unlink('composer-setup.php'); exit(1); }"
php composer-setup.php --install-dir="/usr/local/bin" --filename=composer
rm -f composer-setup.php
echo 'Done!'
