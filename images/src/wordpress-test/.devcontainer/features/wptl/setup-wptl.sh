#!/bin/sh

set -e

download_wp() {
	BASE_DIR="/usr/src/wordpress"
	VERSION="$1"
	if [ "${VERSION}" = "nightly" ] || [ "${VERSION}" = "trunk" ]; then
		TESTS_TAG="trunk"
	elif [ "${VERSION}" = "latest" ]; then
		VERSIONS=$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - )
		LATEST=$(echo "${VERSIONS}" | jq -r '.offers | map(select( .response == "upgrade")) | .[0].version')
		if [ -z "${LATEST}" ]; then
			echo "Unable to detect the latest WP version"
			exit 1
		fi

		download_wp "${LATEST}"
		ln -sf "${BASE_DIR}/wordpress-${LATEST}"           ${BASE_DIR}/wordpress-latest
		ln -sf "${BASE_DIR}/wordpress-tests-lib-${LATEST}" ${BASE_DIR}/wordpress-tests-lib-latest
		return
	elif [ "${VERSION%.x}" != "${VERSION}" ]; then
		VER="${VERSION}"
		LATEST=$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq --arg version "${VERSION%.x}" -r '.offers | map(select(.version | startswith($version))) | sort_by(.version) | reverse | .[0].version')
		download_wp "${LATEST}"
		ln -sf "${BASE_DIR}/wordpress-${LATEST}"           "${BASE_DIR}/wordpress-${VER}"
		ln -sf "${BASE_DIR}/wordpress-tests-lib-${LATEST}" "${BASE_DIR}/wordpress-tests-lib-${VER}"
		return
	else
		TESTS_TAG="tags/${VERSION}"
	fi

	if [ ! -d "${BASE_DIR}/wordpress-${VERSION}" ]; then
		if [ "${VERSION}" = "nightly" ]; then
			cd ${BASE_DIR}
			wget -q https://wordpress.org/nightly-builds/wordpress-latest.zip
			unzip -q wordpress-latest.zip
			mv "${BASE_DIR}/wordpress" "${BASE_DIR}/wordpress-nightly"
			rm -f wordpress-latest.zip
			cd -
		else
			mkdir -p "${BASE_DIR}/wordpress-${VERSION}"
			wget -q "https://wordpress.org/wordpress-${VERSION}.tar.gz" -O - | tar --strip-components=1 -zxm -f - -C "${BASE_DIR}/wordpress-${VERSION}"
		fi
		wget -q https://raw.github.com/markoheijnen/wp-mysqli/master/db.php -O "${BASE_DIR}/wordpress-${VERSION}/wp-content/db.php"
	fi

	if [ ! -d "${BASE_DIR}/wordpress-tests-lib-${VERSION}" ]; then
		mkdir -p "${BASE_DIR}/wordpress-tests-lib-${VERSION}"
		svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}/tests/phpunit/includes/" "${BASE_DIR}/wordpress-tests-lib-${VERSION}/includes"
		svn co --quiet --ignore-externals "https://develop.svn.wordpress.org/${TESTS_TAG}/tests/phpunit/data/"     "${BASE_DIR}/wordpress-tests-lib-${VERSION}/data"
		rm -f "${BASE_DIR}/wordpress-tests-lib-${VERSION}/wp-tests-config-sample.php"
		wget -q "https://develop.svn.wordpress.org/${TESTS_TAG}/wp-tests-config-sample.php" -O "${BASE_DIR}/wordpress-tests-lib-${VERSION}/wp-tests-config-sample.php"
	fi
}

download_wp "${1:-latest}"
