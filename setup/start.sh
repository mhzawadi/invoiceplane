#!/bin/sh

ln -s /dev/stdout /var/log/php81/error.log
ln -s /dev/stdout /var/log/nginx/access.log
ln -s /dev/stdout /var/log/nginx/error.log


if [ ! -f "/var/www/html/ipconfig.php" ]; then

    /var/www/html/ipconfig.php.example > /var/www/html/ipconfig.php

else

    [ -n "$IP_URL" ] && sed -i 's/IP_URL=/IP_URL=${IP_URL}/' /var/www/html/ipconfig.php
    [ -n "$ENABLE_DEBUG" ] && sed -i 's/ENABLE_DEBUG=/ENABLE_DEBUG=${ENABLE_DEBUG}/' /var/www/html/ipconfig.php
    [ -n "$DISABLE_SETUP" ] && sed -i 's/DISABLE_SETUP=/DISABLE_SETUP=${DISABLE_SETUP}/' /var/www/html/ipconfig.php
    [ -n "$REMOVE_INDEXPHP" ] && sed -i 's/REMOVE_INDEXPHP=/REMOVE_INDEXPHP=${REMOVE_INDEXPHP}/' /var/www/html/ipconfig.php

    [ -n "$DB_HOSTNAME" ] && sed -i 's/DB_HOSTNAME=/DB_HOSTNAME=${MYSQL_HOST}/' /var/www/html/ipconfig.php
    [ -n "$DB_USERNAME" ] && sed -i 's/DB_USERNAME=/DB_USERNAME=${DB_USERNAME}/' /var/www/html/ipconfig.php
    [ -n "$DB_PASSWORD" ] && sed -i 's/DB_PASSWORD=/DB_PASSWORD=${DB_PASSWORD}/' /var/www/html/ipconfig.php
    [ -n "$DB_DATABASE" ] && sed -i 's/DB_DATABASE=/DB_DATABASE=${DB_DATABASE}/' /var/www/html/ipconfig.php
    [ -n "$DB_PORT" ] && sed -i 's/DB_PORT=/DB_PORT=${DB_PORT}/' /var/www/html/ipconfig.php

    [ -n "$SESS_EXPIRATION" ] && sed -i 's/SESS_EXPIRATION=/SESS_EXPIRATION=${SESS_EXPIRATION}/' /var/www/html/ipconfig.php
    [ -n "$SESS_MATCH_IP" ] && sed -i 's/SESS_MATCH_IP=/SESS_MATCH_IP=${SESS_MATCH_IP}/' /var/www/html/ipconfig.php
    [ -n "$ENABLE_INVOICE_DELETION" ] && sed -i 's/ENABLE_INVOICE_DELETION=/ENABLE_INVOICE_DELETION=${ENABLE_INVOICE_DELETION}/' /var/www/html/ipconfig.php
    [ -n "$DISABLE_READ_ONLY" ] && sed -i 's/DISABLE_READ_ONLY=/DISABLE_READ_ONLY=${DISABLE_READ_ONLY}/' /var/www/html/ipconfig.php

    ### CRITICAL
    if [ -n "$SETUP_COMPLETED" ]; then
        [ -n "$ENCRYPTION_KEY" ] && sed -i 's/ENCRYPTION_KEY=/ENCRYPTION_KEY=${ENCRYPTION_KEY}/' /var/www/html/ipconfig.php
        [ -n "$ENCRYPTION_CIPHER" ] && sed -i 's/ENCRYPTION_CIPHER=/ENCRYPTION_CIPHER=${ENCRYPTION_CIPHER}/' /var/www/html/ipconfig.php
        sed -i 's/SETUP_COMPLETED=/SETUP_COMPLETED=${SETUP_COMPLETED}/' /var/www/html/ipconfig.php
    fi
fi

chown nobody:nginx /var/www/html/ipconfig.php;
chown -R nobody:nginx /var/www/html/uploads;
chown -R nobody:nginx /var/www/html/assets/core/css;
chown -R nobody:nginx /var/www/html/application/views;

php-fpm81

exec "$@"
