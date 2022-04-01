FROM alpine:3.15
MAINTAINER Matthew Horwood <matt@horwood.biz>

RUN apk update                             \
    &&  apk add nginx php7-fpm php7-curl php7-dom php7-xml php7-xmlwriter    \
    php7-tokenizer php7-simplexml php7-gd php7-gmp php7-gettext php7-pcntl \
		php7-mysqli php7-sockets php7-ctype php7-pecl-mcrypt php7-xmlrpc php7-json \
    php7-session php7-mbstring php7-openssl php7-mysqlnd composer curl\
    && rm -f /var/cache/apk/* \
    && mkdir -p /var/www/html/ \
  	&& mkdir -p /run/nginx;

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.5.11" \
    MYSQL_HOST="mysql" \
    MYSQL_USER="root" \
    MYSQL_PASSWORD="my-secret-pw" \
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
    chmod +x /config/start.sh; \
    cp /config/php.ini /etc/php7/php.ini && \
    cp /config/php_fpm_site.conf /etc/php7/php-fpm.d/www.conf; \
    cp /config/nginx_site.conf /etc/nginx/http.d/default.conf; \
    chown nobody:nginx /var/www/html/* -R;

VOLUME /var/www/html/uploads
EXPOSE 80
ENTRYPOINT ["/config/start.sh"]
CMD ["nginx", "-g", "daemon off;"]

## Health Check
HEALTHCHECK --interval=1m --timeout=3s --start-period=5s \
  CMD curl -f http://127.0.0.1/index.php || exit 1
