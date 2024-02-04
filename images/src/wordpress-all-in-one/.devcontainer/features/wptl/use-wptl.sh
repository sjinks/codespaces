#!/bin/sh

: "${WP_VERSION:="${1:-latest}"}"

BASE_DIR="/usr/src/wordpress"

WP_DB_USER=wordpress_test
WP_DB_PASSWORD=wordpress_test
WP_DB_NAME=wordpress_test
WP_DB_HOST=127.0.0.1

db_admin_user=root

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

echo "Configuring WordPress Test Library..."
if [ ! -d "${BASE_DIR}/wordpress-${WP_VERSION}" ] || [ ! -d "${BASE_DIR}/wordpress-tests-lib-${WP_VERSION}" ]; then
    setup-wptl "${WP_VERSION}"
fi

(
    cd "${BASE_DIR}/wordpress-tests-lib-${WP_VERSION}" && \
    cp -f wp-tests-config-sample.php wp-tests-config.php && \
    sed -i "s/youremptytestdbnamehere/${WP_DB_NAME}/; s/yourusernamehere/${WP_DB_USER}/; s/yourpasswordhere/${WP_DB_PASSWORD}/; s|localhost|${WP_DB_HOST}|; s:dirname( __FILE__ ) . '/src/':'/tmp/wordpress/':" wp-tests-config.php
)

rm -rf /tmp/wordpress /tmp/wordpress-tests-lib
ln -sf "${BASE_DIR}/wordpress-${WP_VERSION}" /tmp/wordpress
ln -sf "${BASE_DIR}/wordpress-tests-lib-${WP_VERSION}" /tmp/wordpress-tests-lib
echo "Done!"
