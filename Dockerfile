FROM alpine:3.23
LABEL org.opencontainers.image.authors="matt@horwood.biz"

RUN apk update                             \
    &&  apk add nginx php83-fpm php83-session \
    php83-gd php83-mbstring php83-mysqli php83-openssl \
    php83-xml php83-dom php83-intl php83-bcmath php83-iconv \
    composer curl \
    && rm -f /var/cache/apk/* \
    && mkdir -p /var/www/html/ \
    && mkdir -p /run/nginx; \
    [ -f /usr/bin/php ] && rm -f /usr/bin/php; \
    ln -s /usr/bin/php83 /usr/bin/php;

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.7.0" \
    MYSQL_HOST="mariadb_10_4" \
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
    cp /config/php.ini /etc/php83/php.ini && \
    cp /config/php_fpm_site.conf /etc/php83/php-fpm.d/www.conf; \
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
