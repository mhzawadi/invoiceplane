#!/bin/sh

ln -s /dev/stdout /var/log/php82/error.log
ln -s /dev/stdout /var/log/nginx/access.log
ln -s /dev/stdout /var/log/nginx/error.log


if [ ! -f "/var/www/html/ipconfig.php" ]
then
  cp /var/www/html/ipconfig.php.example /var/www/html/ipconfig.php
fi

[ -n "$IP_URL" ] && sed -i -e "s!^IP_URL=\$!IP_URL=${IP_URL}!" /var/www/html/ipconfig.php;
[ -n "$ENABLE_DEBUG" ] && sed -i -e "s/ENABLE_DEBUG=.*/ENABLE_DEBUG=${ENABLE_DEBUG}/" /var/www/html/ipconfig.php;
[ -n "$DISABLE_SETUP" ] && sed -i -e "s/DISABLE_SETUP=.*/DISABLE_SETUP=${DISABLE_SETUP}/" /var/www/html/ipconfig.php;
[ -n "$REMOVE_INDEXPHP" ] && sed -i -e "s/REMOVE_INDEXPHP=.*/REMOVE_INDEXPHP=${REMOVE_INDEXPHP}/" /var/www/html/ipconfig.php;

[ -n "$MYSQL_HOST" ] && sed -i -e "s/^DB_HOSTNAME=$/DB_HOSTNAME=${MYSQL_HOST}/" /var/www/html/ipconfig.php;
[ -n "$MYSQL_USER" ] && sed -i -e "s/^DB_USERNAME=$/DB_USERNAME=${MYSQL_USER}/" /var/www/html/ipconfig.php;
[ -n "$MYSQL_PASSWORD" ] && sed -i -e "s/^DB_PASSWORD=$/DB_PASSWORD=${MYSQL_PASSWORD}/" /var/www/html/ipconfig.php;
[ -n "$MYSQL_DB" ] && sed -i -e "s/^DB_DATABASE=$/DB_DATABASE=${MYSQL_DB}/" /var/www/html/ipconfig.php;
[ -n "$MYSQL_PORT" ] && sed -i -e "s/^DB_PORT=$/DB_PORT=${MYSQL_PORT}/" /var/www/html/ipconfig.php;

[ -n "$SESS_EXPIRATION" ] && sed -i -e "s/^SESS_EXPIRATION=$/SESS_EXPIRATION=${SESS_EXPIRATION}/" /var/www/html/ipconfig.php;
[ -n "$SESS_MATCH_IP" ] && sed -i -e "s/^SESS_MATCH_IP=$/SESS_MATCH_IP=${SESS_MATCH_IP}/" /var/www/html/ipconfig.php;
[ -n "$ENABLE_INVOICE_DELETION" ] && sed -i -e "s/^ENABLE_INVOICE_DELETION=$/ENABLE_INVOICE_DELETION=${ENABLE_INVOICE_DELETION}/" /var/www/html/ipconfig.php;
[ -n "$DISABLE_READ_ONLY" ] && sed -i -e "s/^DISABLE_READ_ONLY=$/DISABLE_READ_ONLY=${DISABLE_READ_ONLY}/" /var/www/html/ipconfig.php;

### CRITICAL
if [ -n "$SETUP_COMPLETED" ]; then
    [ -n "$ENCRYPTION_KEY" ] && sed -i -e "s/ENCRYPTION_KEY=.*/ENCRYPTION_KEY=${ENCRYPTION_KEY}/" /var/www/html/ipconfig.php;
    [ -n "$ENCRYPTION_CIPHER" ] && sed -i -e "s/ENCRYPTION_CIPHER=.*/ENCRYPTION_CIPHER=${ENCRYPTION_CIPHER}/" /var/www/html/ipconfig.php;
    sed -i -e "s/SETUP_COMPLETED=.*/SETUP_COMPLETED=${SETUP_COMPLETED}/" /var/www/html/ipconfig.php;
fi

chown nobody:nginx /var/www/html/ipconfig.php;
chown -R nobody:nginx /var/www/html/uploads;
chown -R nobody:nginx /var/www/html/assets/core/css;
chown -R nobody:nginx /var/www/html/application/views;

php-fpm82

exec "$@"
