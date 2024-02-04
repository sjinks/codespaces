#!/bin/sh

export XDEBUG_MODE=off

if [ -z "${WP_DOMAIN}" ]; then
    WP_DOMAIN="${1:-localhost}"
fi

if [ -z "${WP_MULTISITE_TYPE}" ]; then
    WP_MULTISITE_TYPE="${2:-}"
fi

if [ -n "${CODESPACE_NAME}" ] && [ -n "${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}" ]; then
    WP_DOMAIN="${CODESPACE_NAME}-80.${GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN}"
fi

WP_DB_USER=wordpress
WP_DB_PASSWORD=wordpress
WP_DB_NAME=wordpress
WP_DB_HOST=127.0.0.1
db_admin_user=root
wp_url="http://${WP_DOMAIN}"
wp_title="WordPress Development Site"

if [ -n "${WP_MULTISITE_TYPE}" ]; then
    multisite_domain="${WP_DOMAIN}"
    multisite_type="${WP_MULTISITE_TYPE}"
    if [ -n "${CODESPACE_NAME}" ]; then
        multisite_type="subdirectories"
    fi
else
    multisite_domain=
    multisite_type=
fi

MY_UID="$(id -u)"
MY_GID="$(id -g)"

sudo install -d -o "${MY_UID}" -g "${MY_GID}" -m 0755 /workspaces/uploads
ln -sf /workspaces/uploads /wp/wp-content/uploads

echo "Waiting for MySQL to come online..."
second=0
while ! mysqladmin ping -u "${db_admin_user}" -h "${WP_DB_HOST}" --silent && [ "${second}" -lt 60 ]; do
    sleep 1
    second=$((second+1))
done
if ! mysqladmin ping -u "${db_admin_user}" -h "${WP_DB_HOST}" --silent >/dev/null 2>&1; then
    echo "ERROR: mysql has failed to come online"
    exit 1;
fi

echo "Checking for database connectivity..."
if ! mysql -h "${WP_DB_HOST}" -u"${WP_DB_USER}" -p"${WP_DB_PASSWORD}" "${WP_DB_NAME}" -e "SELECT 'testing_db'" >/dev/null 2>&1; then
    echo "No WordPress database exists, provisioning..."
    {
        echo "CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'localhost' IDENTIFIED BY '${WP_DB_PASSWORD}';"
        echo "CREATE USER IF NOT EXISTS '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PASSWORD}';"
        echo "GRANT ALL ON *.* TO '${WP_DB_USER}'@'localhost';"
        echo "GRANT ALL ON *.* TO '${WP_DB_USER}'@'%';"
        echo "CREATE DATABASE IF NOT EXISTS ${WP_DB_NAME};"
    } | mysql -h "${WP_DB_HOST}" -u "${db_admin_user}"
fi

echo "Checking for WordPress installation..."
if ! wp core is-installed >/dev/null 2>&1; then
    echo "No installation found, installing WordPress..."

    sudo install -d -o "${MY_UID}" -g "${MY_GID}" -m 0755 /workspaces/uploads
    ln -sf /workspaces/uploads /wp/wp-content/uploads

    wp config shuffle-salts
    wp db clean --yes 2>/dev/null

    if [ -n "${multisite_domain}" ]; then
        wp config set WP_ALLOW_MULTISITE true --raw
        wp config set MULTISITE true --raw
        wp config set DOMAIN_CURRENT_SITE "${multisite_domain}"
        wp config set PATH_CURRENT_SITE /
        wp config set SITE_ID_CURRENT_SITE 1 --raw
        wp config set BLOG_ID_CURRENT_SITE 1 --raw

        if [ "${multisite_type}" = "subdomain" ]; then
            wp config set SUBDOMAIN_INSTALL true --raw
            type="--subdomains"
        else
            wp config set SUBDOMAIN_INSTALL false --raw
            type=""
        fi
        wp core multisite-install \
            --path=/wp \
            --url="${wp_url}" \
            --title="${wp_title}" \
            --admin_user="admin" \
            --admin_email="admin@localhost.local" \
            --admin_password="password" \
            --skip-email \
            --skip-plugins \
            ${type} \
            --skip-config
    else
        wp core install \
            --path=/wp \
            --url="${wp_url}" \
            --title="${wp_title}" \
            --admin_user="admin" \
            --admin_email="admin@localhost.local" \
            --admin_password="password" \
            --skip-email \
            --skip-plugins
    fi

    wp option set blog_public 0
    run-parts /var/lib/wordpress/postinstall.d
else
    echo "WordPress already installed"
fi
