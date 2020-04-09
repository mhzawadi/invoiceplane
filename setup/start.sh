#!/bin/sh

cp /config/nginx_site.conf /etc/nginx/conf.d/default.conf
ln -s /dev/stdout /var/log/php7/error.log
ln -s /dev/stdout /var/log/nginx/access.log
ln -s /dev/stdout /var/log/nginx/error.log

if [ ! -f "/var/www/html/ipconfig.php" ]; then
  sed \
    -e "s/DB_HOSTNAME=/DB_HOSTNAME=${MYSQL_HOST}/" \
    -e "s/DB_USERNAME=/DB_USERNAME=${MYSQL_USER}/" \
    -e "s/DB_PASSWORD=/DB_PASSWORD=${MYSQL_PASSWORD}/" \
    -e "s/DB_DATABASE=/DB_DATABASE=${MYSQL_DB}/" \
    -e "s/DB_PORT=/DB_PORT=${MYSQL_PORT}/" \
    -e "s!IP_URL=!IP_URL=${IP_URL}!" \
    -e "s/DISABLE_SETUP=false/DISABLE_SETUP=${DISABLE_SETUP}/" \
  /var/www/html/ipconfig.php.example > /var/www/html/ipconfig.php;
fi

chown nobody:nginx /var/www/html/ipconfig.php;

php-fpm7

exec "$@"
