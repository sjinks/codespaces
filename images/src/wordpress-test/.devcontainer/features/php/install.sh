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
    php81 php81-pear \
    php81-pecl-apcu \
    php81-bcmath \
    php81-calendar \
    php81-ctype \
    php81-curl \
    php81-dom \
    php81-exif \
    php81-fileinfo \
    php81-ftp \
    php81-gd \
    php81-gmp \
    php81-iconv \
    php81-intl \
    php81-json \
    php81-mbstring \
    php81-pecl-igbinary \
    php81-pecl-imagick \
    php81-pecl-memcache \
    php81-pecl-memcached \
    php81-mysqli \
    php81-mysqlnd \
    php81-opcache \
    php81-openssl \
    php81-pcntl \
    php81-pdo \
    php81-pdo_sqlite \
    php81-phar \
    php81-posix \
    php81-session \
    php81-shmop \
    php81-simplexml \
    php81-soap \
    php81-sockets \
    php81-sodium \
    php81-sqlite3 \
    php81-sysvsem \
    php81-sysvshm \
    php81-tokenizer \
    php81-xml \
    php81-xmlreader \
    php81-xmlwriter \
    php81-zip \
    php81-pecl-pcov

[ ! -f /usr/bin/php ] && ln -s /usr/bin/php81 /usr/bin/php
[ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl81 /usr/bin/pecl
[ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear81 /usr/bin/pear
[ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev81 /usr/bin/peardev
[ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar81 /usr/bin/phar
[ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar81 /usr/bin/phar.phar

PHP_INI_DIR=/etc/php81
echo "export PHP_INI_DIR=${PHP_INI_DIR}" > /etc/profile.d/php_ini_dir.sh

getent group www-data > /dev/null || addgroup -g 82 -S www-data
getent passwd www-data > /dev/null || adduser -u 82 -D -S -G www-data -H www-data

pecl update-channels
rm -rf /tmp/pear ~/.pearrc

install -m 0644 php.ini "${PHP_INI_DIR}/php.ini"

wget -q https://getcomposer.org/installer -O composer-setup.php
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('sha384', 'composer-setup.php') === '${HASH}') { echo 'Installer verified', PHP_EOL; } else { echo 'Installer corrupt', PHP_EOL; unlink('composer-setup.php'); exit(1); }"
php composer-setup.php --install-dir="/usr/local/bin" --filename=composer
rm -f composer-setup.php
echo 'Done!'
