FROM alpine:3.9.4
MAINTAINER Matthew Horwood <matt@horwood.biz>

RUN apk update                             \
    &&  apk add nginx php7-fpm php7-curl php7-dom php7-xml php7-xmlwriter    \
    php7-tokenizer php7-simplexml php7-gd php7-gmp php7-gettext php7-pcntl \
		php7-mysqli php7-sockets php7-ctype php7-pecl-mcrypt php7-xmlrpc       \
    php7-session composer \
    && rm -f /var/cache/apk/* \
    && mkdir -p /var/www/html/ \
  	&& mkdir -p /run/nginx;

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.5.9" \
    MYSQL_HOST="localhost" \
    MYSQL_USER="invoiceplane" \
    MYSQL_PASSWORD="invoiceplane" \
    MYSQL_DB="invoiceplane" \
    MYSQL_PORT="3306" \
    IP_URL="http://127.0.0.1" \
    HOST_URL="127.0.0.1" \
    DISABLE_SETUP="false"

COPY setup /config
WORKDIR /var/www/html
# copy invoiceplane sources to web dir
ADD ${IP_SOURCE}/${IP_VERSION}/${IP_VERSION}.zip /tmp/
RUN unzip /tmp/${IP_VERSION}.zip           && \
    mv ./ip/* ./                           && \
    chmod +x /config/start.sh; \
    cp /config/php.ini /etc/php7/php.ini && \
		cp /config/php_fpm_site.conf /etc/php7/php-fpm.d/www.conf; \
    sed \
      -e "s/DB_HOSTNAME=/DB_HOSTNAME=getenv(\"MYSQL_HOST\")/" \
      -e "s/DB_USERNAME=/DB_USERNAME=getenv(\"MYSQL_USER\")/" \
      -e "s/DB_PASSWORD=/DB_PASSWORD=getenv(\"MYSQL_PASSWORD\")/" \
      -e "s/DB_DATABASE=/DB_DATABASE=getenv(\"MYSQL_DB\")/" \
      -e "s/DB_PORT=/DB_PORT=getenv(\"MYSQL_PORT\")/" \
      -e "s/IP_URL=/IP_URL=getenv(\"IP_URL\")/" \
      -e "s/DISABLE_SETUP=false/DISABLE_SETUP=getenv(\"DISABLE_SETUP\")/" \
    /var/www/html/ipconfig.php.example > /var/www/html/ipconfig.php && \
    chown nobody:nginx /var/www/html/* -R;

VOLUME /var/www/html/uploads
EXPOSE 80
ENTRYPOINT ["/config/start.sh"]
CMD ["nginx", "-g", "daemon off;"]
