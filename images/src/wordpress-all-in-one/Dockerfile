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
        php81@edget \
        php81-fpm@edget \
        php81-pear@edget \
        php81-pecl-apcu@edget \
        php81-bcmath@edget \
        php81-calendar@edget \
        php81-ctype@edget \
        php81-curl@edget \
        php81-dom@edget \
        php81-exif@edget \
        php81-fileinfo@edget \
        php81-ftp@edget \
        php81-gd@edget \
        php81-pecl-imagick@edget \
        php81-gmp@edget \
        php81-iconv@edget \
        php81-intl@edget \
        php81-json@edget \
        php81-mbstring@edget \
        php81-pecl-memcache@edget \
        php81-pecl-memcached@edget \
        php81-mysqli@edget \
        php81-mysqlnd@edget \
        php81-opcache@edget \
        php81-openssl@edget \
        php81-pcntl@edget \
        php81-pdo@edget \
        php81-pdo_sqlite@edget \
        php81-phar@edget \
        php81-posix@edget \
        php81-session@edget \
        php81-shmop@edget \
        php81-simplexml@edget \
        php81-soap@edget \
        php81-sockets@edget \
        php81-sodium@edget \
        php81-sqlite3@edget \
        php81-sysvsem@edget \
        php81-sysvshm@edget \
        php81-tokenizer@edget \
        php81-xml@edget \
        php81-xmlreader@edget \
        php81-xmlwriter@edget \
        php81-zip@edget

# PHP
ENV PHP_INI_DIR /etc/php81
RUN \
    ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm && \
    install -d -m 0750 -o "${CONTAINER_USER}" -g adm /var/log/php-fpm && \
    echo "export PHP_INI_DIR=/etc/php81" > /etc/profile.d/php_ini_dir.sh && \
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
