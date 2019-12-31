FROM alpine:3.9.4
MAINTAINER Matthew Horwood <matt@horwood.biz>

RUN apk update                             \
    &&  apk add php7-apache2 php7-curl php7-dom php7-xml php7-xmlwriter    \
    php7-tokenizer php7-simplexml php7-gd php7-gmp php7-gettext php7-pcntl \
		php7-mysqli php7-sockets composer \
    && rm -f /var/cache/apk/* \
    && mkdir -p /var/www/html;

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.5.9" \
    MYSQL_HOST="localhost" \
    MYSQL_USER="invoiceplane" \
    MYSQL_PASSWORD="invoiceplane" \
    MYSQL_DB="invoiceplane" \
    MYSQL_PORT="3306" \
    IP_URL="http://invoiceplane.local" \
    DISABLE_SETUP="false"

COPY php.ini /etc/php7/
WORKDIR /var/www/html
# copy invoiceplane sources to web dir
ADD ${IP_SOURCE}/${IP_VERSION}/${IP_VERSION}.zip /tmp/
RUN unzip /tmp/${IP_VERSION}.zip && \
    mv ./ip/* ./ && \
    cp ipconfig.php.example ipconfig.php && \
		chown apache:apache /var/www/html/* -R;

# Use system environment variables into config.php
RUN sed -i \
    -e "s/DB_HOSTNAME=/DB_HOSTNAME=getenv(\"MYSQL_HOST\")/" \
    -e "s/DB_USERNAME=/DB_USERNAME=getenv(\"MYSQL_USER\")/" \
    -e "s/DB_PASSWORD=/DB_PASSWORD=getenv(\"MYSQL_PASSWORD\")/" \
    -e "s/DB_DATABASE=/DB_DATABASE=getenv(\"MYSQL_DB\")/" \
    -e "s/DB_PORT=/DB_PORT=getenv(\"MYSQL_PORT\")/" \
    -e "s/IP_URL=/IP_URL=getenv(\"IP_URL\")/" \
    -e "s/DISABLE_SETUP=false/DISABLE_SETUP=getenv(\"DISABLE_SETUP\")/" \
    /var/www/html/ipconfig.php

VOLUME /var/www/html/uploads
EXPOSE 80
