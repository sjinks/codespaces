<?php

require( dirname( __FILE__ ) . '/wp-config-defaults.php' );

define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'wordpress' );
define( 'DB_PASSWORD', 'wordpress' );
define( 'DB_HOST', '127.0.0.1' );

define( 'DB_CHARSET', 'utf8mb4' );
if ( ! defined( 'DB_COLLATE' ) ) {
	define( 'DB_COLLATE', '' );
}

$table_prefix = 'wp_';

if ( ! defined( 'WP_DEBUG' ) ) {
	define( 'WP_DEBUG', true );
}

if ( ! defined( 'WP_DEBUG_DISPLAY' ) ) {
	define( 'WP_DEBUG_DISPLAY', false );
}

// If we're behind a proxy server and using HTTPS, we need to alert WordPress of that fact
// see also https://wordpress.org/support/article/administration-over-ssl/#using-a-reverse-proxy
// phpcs:ignore WordPress.Security.ValidatedSanitizedInput.InputNotSanitized
if ( isset( $_SERVER['HTTP_X_FORWARDED_PROTO'] ) && strpos( $_SERVER['HTTP_X_FORWARDED_PROTO'], 'https' ) !== false ) {
	$_SERVER['HTTPS'] = 'on';
}

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );
}

// phpcs:disable WordPress.Security.ValidatedSanitizedInput.InputNotSanitized
if ( ! empty( $_SERVER['HTTP_X_FORWARDED_HOST'] ) && substr( $_SERVER['HTTP_X_FORWARDED_HOST'], -strlen( '.github.dev' ) ) === '.github.dev' ) {
	$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
	$_ENV['HTTP_HOST']    = $_SERVER['HTTP_HOST'];  // phpcs:ignore WordPress.Security.ValidatedSanitizedInput.InputNotValidated
}

if ( isset( $_SERVER['HTTP_HOST'] ) && count( explode( ':', $_SERVER['HTTP_HOST'], 2 ) ) === 2 ) {
	$proto = $_SERVER['HTTP_X_FORWARDED_PROTO'] ?? 'http';
	if ( ! defined( 'WP_HOME' ) ) {
		define( 'WP_HOME', $proto . '://' . $_SERVER['HTTP_HOST'] );
	}

	if ( ! defined( 'WP_SITEURL' ) ) {
		define( 'WP_SITEURL', $proto . '://' . $_SERVER['HTTP_HOST'] );
	}
}
// phpcs:enable

/** Sets up WordPress vars and included files. */
/** @psalm-suppress UnresolvableInclude */
require_once( ABSPATH . 'wp-settings.php' );
