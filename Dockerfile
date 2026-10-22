FROM alpine:3.24
LABEL org.opencontainers.image.authors="matt@horwood.biz"

RUN apk update                             \
    && apk add nginx php85-fpm php85-session \
    php85-gd php85-mbstring php85-mysqli php85-openssl \
    php85-xml php85-dom php85-intl php85-bcmath php85-iconv \
    composer curl \
    && rm -f /var/cache/apk/* \
    && mkdir -p /var/www/html/ \
    && mkdir -p /run/nginx \
    && mkdir -p /var/lib/invoiceplane/sessions; \
    [ -f /usr/bin/php ] && rm -f /usr/bin/php; \
    ln -s /usr/bin/php85 /usr/bin/php;

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.7.2" \
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
    cp /config/php.ini /etc/php85/php.ini && \
    cp /config/php_fpm_site.conf /etc/php85/php-fpm.d/www.conf; \
    cp /config/nginx_site.conf /etc/nginx/http.d/default.conf; \
    chown nobody:nginx /var/www/html/* -R \
    && chown nobody:nginx /var/lib/invoiceplane/sessions;

WORKDIR /var/www/html

VOLUME /var/www/html/uploads /var/www/html/assets/core/css /var/www/html/application/views
EXPOSE 80
ENTRYPOINT ["/config/start.sh"]
CMD ["nginx", "-g", "daemon off;"]

## Health Check
HEALTHCHECK --interval=1m --timeout=3s --start-period=5s \
  CMD curl -f http://127.0.0.1/index.php || exit 1
