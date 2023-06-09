FROM ghcr.io/sjinks/codespaces/alpine-base:latest

RUN \
    grep -Eq '^@edgec' /etc/apk/repositories || echo "@edgec https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    grep -Eq '^@edgem' /etc/apk/repositories || echo "@edgem https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    grep -Eq '^@edget' /etc/apk/repositories || echo "@edget https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN \
    apk add --no-cache \
        nginx \
        mariadb mariadb-client \
        memcached \
        nodejs@edgem npm@edgem python3 make g++ \
        icu-data-full@edgem icu-libs@edgem libssl3@edgem ghostscript \
        imagemagick-libs@edgec \
        php8@edget \
        php8-fpm@edget \
        php8-pear@edget \
        php8-pecl-apcu@edget \
        php8-bcmath@edget \
        php8-calendar@edget \
        php8-ctype@edget \
        php8-curl@edget \
        php8-dom@edget \
        php8-exif@edget \
        php8-fileinfo@edget \
        php8-ftp@edget \
        php8-gd@edget \
        php8-pecl-imagick@edget \
        php8-gmp@edget \
        php8-iconv@edget \
        php8-intl@edget \
        php8-json@edget \
        php8-mbstring@edget \
        php8-pecl-memcache@edget \
        php8-pecl-memcached@edget \
        php8-mysqli@edget \
        php8-mysqlnd@edget \
        php8-opcache@edget \
        php8-openssl@edget \
        php8-pcntl@edget \
        php8-pdo@edget \
        php8-pdo_sqlite@edget \
        php8-phar@edget \
        php8-posix@edget \
        php8-session@edget \
        php8-shmop@edget \
        php8-simplexml@edget \
        php8-soap@edget \
        php8-sockets@edget \
        php8-sodium@edget \
        php8-sqlite3@edget \
        php8-sysvsem@edget \
        php8-sysvshm@edget \
        php8-tokenizer@edget \
        php8-xml@edget \
        php8-xmlreader@edget \
        php8-xmlwriter@edget \
        php8-zip@edget

# PHP
ENV PHP_INI_DIR /etc/php8
RUN \
    ln -s /usr/sbin/php-fpm8 /usr/sbin/php-fpm && \
    ln -s /usr/bin/php8 /usr/bin/php && \
    ln -s /usr/bin/pecl8 /usr/bin/pecl && \
    ln -s /usr/bin/pear8 /usr/bin/pear && \
    ln -s /usr/bin/peardev8 /usr/bin/peardev && \
    ln -s /usr/bin/phar8 /usr/bin/phar && \
    ln -s /usr/bin/phar8 /usr/bin/phar.phar && \
    install -d -m 0750 -o "${CONTAINER_USER}" -g adm /var/log/php-fpm && \
    echo "export PHP_INI_DIR=/etc/php8" > /etc/profile.d/php_ini_dir.sh && \
    pecl update-channels && \
    rm -rf /tmp/pear ~/.pearrc && \
    wget -q https://getcomposer.org/installer -O - | php -- --install-dir=/usr/bin/ --filename=composer

# WP-CLI
ENV WP_CLI_CONFIG_PATH /etc/wp-cli/wp-cli.yml
RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod 0755 /usr/local/bin/wp

# nginx
RUN \
    sed -i "s/user nginx;/user ${CONTAINER_USER};/" /etc/nginx/nginx.conf && \
    chown -R "${CONTAINER_USER}:${CONTAINER_USER}" /run/nginx /var/log/nginx /var/lib/nginx

# Mailpit
RUN \
    set -e; \
    ARCH="$(arch)"; \
    LATEST=$(curl -w '%{url_effective}' -I -L -s -S https://github.com/axllent/mailpit/releases/latest -o /dev/null | sed -e 's|.*/||'); \
    if [ "${ARCH}" = "arm64" ] || [ "${ARCH}" = "aarch64" ]; then \
        ARCH="arm64"; \
    elif [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then \
        ARCH="amd64"; \
    else \
        echo "(!) Unsupported architecture: ${ARCH}"; \
        exit 1; \
    fi; \
    mkdir -p /tmp/mailpit; \
    cd /tmp/mailpit; \
    wget -q "https://github.com/axllent/mailpit/releases/download/${LATEST}/mailpit-linux-${ARCH}.tar.gz" -O - | tar -xz; \
    install -m 0755 -o root -g root mailpit /usr/local/bin/mailpit; \
    cd ..; \
    rm -rf /tmp/mailpit

COPY rootfs /
COPY --chown=${CONTAINER_USER}:${CONTAINER_USER} wp /wp

# Fix PHP
RUN [ "${CONTAINER_USER}" = 'vscode' ] || sed -i "s/vscode/${CONTAINER_USER}/" /etc/php/php-fpm.d/docker.conf

# WordPress
RUN \
    install -d -o "${CONTAINER_USER}" -g "${CONTAINER_USER}" /wp && \
    su-exec "${CONTAINER_USER}:${CONTAINER_USER}" wp core download --path=/wp
