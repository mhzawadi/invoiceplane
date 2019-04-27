ARG MH_ARCH
ARG MH_TAG
FROM ${MH_ARCH}:${MH_TAG}
MAINTAINER Matthew Horwood <matt@horwood.biz>

# Install required deb packages
RUN apt-get update && \
	apt-get install -y git libgmp-dev libmcrypt-dev libfreetype6-dev libjpeg62-turbo-dev libldb-dev libldap2-dev && \
	ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so && \
	ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so && \
	rm -rf /var/lib/apt/lists/* && \
	docker-php-ext-configure mysqli --with-mysqli=mysqlnd && \
	ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \
	docker-php-ext-configure gmp --with-gmp=/usr/include/x86_64-linux-gnu && \
	docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
	docker-php-ext-install -j$(nproc) pdo_mysql sockets gd gmp ldap gettext pcntl && \
	echo ". /etc/environment" >> /etc/apache2/envvars && \
	a2enmod rewrite

  ENV IP_SOURCE="https://github.com/phpipam/phpipam/archive/" \
      IP_VERSION="v.1.5.9" \
      MYSQL_HOST="mysql" \
      MYSQL_USER="phpipam" \
      MYSQL_PASSWORD="phpipamadmin" \
      MYSQL_DB="phpipam" \
      MYSQL_PORT="3306" \
      IP_URL="false" \
      DISABLE_SETUP="/path/to/cert.key"

COPY php.ini /usr/local/etc/php/

# copy phpipam sources to web dir
ADD ${IP_SOURCE}/${IP_VERSION}.tar.gz /tmp/
RUN tar -xzf /tmp/${IP_VERSION}.tar.gz -C /var/www/html/ --strip-components=1 && \
    cp /var/www/html/ipconfig.php.example /var/www/html/ipconfig.php

# Use system environment variables into config.php
RUN sed -i \
    -e "s/\['DB_HOSTNAME'\] = 'localhost'/\['DB_HOSTNAME'\] = getenv(\"MYSQL_HOST\")/" \
    -e "s/\['DB_USERNAME'\] = 'phpipam'/\['DB_USERNAME'\] = getenv(\"MYSQL_USER\")/" \
    -e "s/\['DB_PASSWORD'\] = 'phpipamadmin'/\['DB_PASSWORD'\] = getenv(\"MYSQL_PASSWORD\")/" \
    -e "s/\['DB_DATABASE'\] = 'phpipam'/\['DB_DATABASE'\] = getenv(\"MYSQL_DB\")/" \
    -e "s/\['DB_PORT'\] = 3306/\['DB_PORT'\] = getenv(\"MYSQL_PORT\")/" \
    -e "s/\['IP_URL'\] *= http://localhost/\['IP_URL'\] = getenv(\"IP_URL\")/" \
    -e "s/\['DISABLE_SETUP'\] *= false/['DISABLE_SETUP'\] = getenv(\"SSL_KEY\")/" \
    /var/www/html/ipconfig.php

EXPOSE 80
