ARG MH_ARCH
ARG MH_TAG
FROM ${MH_ARCH}:${MH_TAG}
MAINTAINER Matthew Horwood <matt@horwood.biz>

# Install required deb packages
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	git libgmp-dev libmcrypt-dev libfreetype6-dev libjpeg62-turbo-dev \
	libldb-dev libldap2-dev unzip && \
	ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so && \
	ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so && \
	rm -rf /var/lib/apt/lists/* && \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
	docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu && \
	docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
	docker-php-ext-install -j$(nproc) mysqli sockets gd gmp ldap gettext pcntl && \
	echo ". /etc/environment" >> /etc/apache2/envvars && \
	a2enmod rewrite

ENV IP_SOURCE="https://github.com/InvoicePlane/InvoicePlane/releases/download" \
    IP_VERSION="v1.5.9" \
    MYSQL_HOST="localhost" \
    MYSQL_USER="invoiceplane" \
    MYSQL_PASSWORD="invoiceplane" \
    MYSQL_DB="invoiceplane" \
    MYSQL_PORT="3306" \
    IP_URL="http://invoiceplane.local" \
    DISABLE_SETUP="false"

COPY php.ini /usr/local/etc/php/
WORKDIR /var/www/html
# copy phpipam sources to web dir
ADD ${IP_SOURCE}/${IP_VERSION}/${IP_VERSION}.zip /tmp/
RUN unzip /tmp/${IP_VERSION}.zip && \
    mv ./ip/* ./ && \
    cp ipconfig.php.example ipconfig.php && \
		chown www-data:www-data /var/www/html/* -R;

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

VOLUME /var/www/html
EXPOSE 80
