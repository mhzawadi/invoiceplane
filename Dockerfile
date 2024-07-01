FROM alpine:3.19
MAINTAINER Matthew Horwood <matt@horwood.biz>

RUN apk update                             \
    &&  apk add nginx php82-fpm php82-session \
    php82-gd php82-mbstring php82-mysqli php82-openssl \
    php82-xml php82-dom php82-intl php82-bcmath composer curl \
    && rm -f /var/cache/apk/* \
    && mkdir -p /var/www/html/ \
  	&& mkdir -p /run/nginx; \
    [ -f /usr/bin/php ] && rm -f /usr/bin/php; \
    ln -s /usr/bin/php82 /usr/bin/php;

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.6.1" \
    MYSQL_HOST="mysql" \
    MYSQL_USER="root" \
    MYSQL_PASSWORD="my-secret-pw" \
    MYSQL_DB="invoiceplane" \
    MYSQL_PORT="3306" \
    IP_URL="http://127.0.0.1" \
    HOST_URL="127.0.0.1" \
    DISABLE_SETUP="false"

COPY setup /config
# copy invoiceplane sources to web dir
ADD ${IP_SOURCE}/${IP_VERSION}/${IP_VERSION}.zip /tmp/
RUN cd /tmp && \
    unzip /tmp/${IP_VERSION}.zip && \
    cp -r ip/* /var/www/html/ && \
    chmod +x /config/start.sh; \
    cp /config/php.ini /etc/php82/php.ini && \
    cp /config/php_fpm_site.conf /etc/php82/php-fpm.d/www.conf; \
    cp /config/nginx_site.conf /etc/nginx/http.d/default.conf; \
    chown nobody:nginx /var/www/html/* -R;

WORKDIR /var/www/html

VOLUME /var/www/html/uploads /var/www/html/assets/core/css /var/www/html/application/views
EXPOSE 80
ENTRYPOINT ["/config/start.sh"]
CMD ["nginx", "-g", "daemon off;"]

## Health Check
HEALTHCHECK --interval=1m --timeout=3s --start-period=5s \
  CMD curl -f http://127.0.0.1/index.php || exit 1
