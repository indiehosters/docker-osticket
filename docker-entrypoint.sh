#!/bin/bash
set -e

if [ ! -e index.php ]; then
	tar cf - --one-file-system -C /usr/src/osticket . | tar xf -
	chown -R www-data ./upload
fi

if [ ! -s /var/www/html/upload/include/ost-config.php ]; then
cat > /var/www/html/upload/include/ost-config.php << EOF
<?php
#Disable direct access.
if(!strcasecmp(basename($_SERVER['SCRIPT_NAME']),basename(__FILE__)) || !defined('INCLUDE_DIR'))
    die('kwaheri rafiki!');

#Install flag
define('OSTINSTALLED',FALSE);
if(OSTINSTALLED!=TRUE){
    if(!file_exists(ROOT_DIR.'setup/install.php')) die('Error: Contact system admin.'); //Something is really wrong!
    //Invoke the installer.
    header('Location: '.ROOT_PATH.'setup/install.php');
    exit;
}
define('SECRET_SALT','%CONFIG-SIRI');
define('ADMIN_EMAIL','%ADMIN-EMAIL');
define('DBTYPE','mysql');
define('DBHOST','%CONFIG-DBHOST');
define('DBNAME','%CONFIG-DBNAME');
define('DBUSER','%CONFIG-DBUSER');
define('DBPASS','%CONFIG-DBPASS');
define('TABLE_PREFIX','%CONFIG-PREFIX');
?>
EOF
else
  rm -rf ./upload/setup
fi

cat > /etc/ssmtp/ssmtp.conf << EOF
UseTLS=${MAIL_TLS}
UseSTARTTLS=${MAIL_STARTTLS}
root=${MAIL_USER}
mailhub=${MAIL_HOST}:${MAIL_PORT}
hostname=${MAIL_HOST}
AuthUser=${MAIL_USER}
AuthPass=${MAIL_PASS}
EOF

echo "www-data:${MAIL_USER}:${MAIL_HOST}:${MAIL_PORT}" >> /etc/ssmtp/revaliases

exec "$@"
