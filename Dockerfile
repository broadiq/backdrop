# from https://backdropcms.org/requirements
FROM php:5.6-apache

RUN a2enmod rewrite

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libpq-dev \
	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip

WORKDIR /var/www/html

# https://github.com/backdrop/backdrop/releases
ENV BACKDROP_VERSION 1.10.1
ENV BACKDROP_MD5 1c6582dfbf8ecd422e4338e3a5157504

RUN curl -fSL "https://github.com/backdrop/backdrop/archive/${BACKDROP_VERSION}.tar.gz" -o backdrop.tar.gz \
  && echo "${BACKDROP_MD5} *backdrop.tar.gz" | md5sum -c - \
  && tar -xz --strip-components=1 -f backdrop.tar.gz \
  && rm backdrop.tar.gz \
  && chown -R www-data:www-data sites \
  && chown -R www-data:www-data .

# Add custom entrypoint to set BACKDROP_SETTINGS correctly
COPY docker-entrypoint.sh /entrypoint.sh

COPY settings.php /var/www/html

RUN chmod 777 /var/www/html/settings.php

RUN chmod 777 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
