<?php

defined( 'ABSPATH' ) || die();

add_filter( 'wp_mail_from', function ( $email ) {
	if ( 'wordpress@' === $email || 'wordpress@localhost' === $email ) {
		$email = 'wordpress@localhost.localdomain';
	}

	return $email;
}, 0 );
