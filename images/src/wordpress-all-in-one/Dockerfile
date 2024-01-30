FROM ghcr.io/sjinks/codespaces/alpine-base:latest@sha256:1efdeae0e62d9fc8952846940eea4cbff17296e46b91cbe1c2e561617a671287

RUN \
    apk add --no-cache \
        nginx \
        mariadb mariadb-client \
        memcached \
        nodejs npm python3 make g++ \
        icu-data-full icu-libs libssl3 ghostscript \
        imagemagick-libs \
        php81 \
        php81-fpm \
        php81-pear \
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
        php81-pecl-imagick \
        php81-gmp \
        php81-iconv \
        php81-intl \
        php81-json \
        php81-mbstring \
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
        php81-zip

# PHP
ENV PHP_INI_DIR /etc/php81
RUN \
    ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm && \
    ln -s /usr/bin/pecl81 /usr/bin/pecl && \
    ln -s /usr/bin/php81 /usr/bin/php && \
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
