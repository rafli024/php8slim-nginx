# Maintainer : Muhammad Rafli
# Version: 1.0
# Description: Dockerfile for php slim 8.1 and nginx

FROM php:8.1-fpm

RUN apt update \
    && apt install -y nginx curl git zip unzip wget haveged acl libicu-dev libzip-dev \
    && docker-php-ext-install mysqli pdo pdo_mysql \ 
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-install intl opcache \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-enable intl \
    && pecl install apcu \
    && docker-php-ext-enable apcu \
    && docker-php-ext-configure zip \  
    && docker-php-ext-install zip

RUN mkdir /var/www/slim_app
COPY /config/nginx/nginx-site.conf /etc/nginx/sites-available/default
COPY ./slim_app/ /var/www/slim_app
COPY /config/php/php.ini ./usr/local/etc/php/php.ini

COPY startService.sh /root/startService.sh

RUN chmod +x /root/startService.sh

# Delete comment below if want to try it in localhost
# RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN sed -i "s/^\(upload_max_filesize\).*/\1 $(eval echo = \${upload_max_filesize=256M})/" ./usr/local/etc/php/php.ini \
    && sed -i "s/^\(post_max_size\).*/\1 $(eval echo = \${post_max_size=256M})/" ./usr/local/etc/php/php.ini

RUN chmod -R 775 /var/www/slim_app
RUN chown -R www-data:www-data /var/www/slim_app

EXPOSE 80

# start proccess nginx
WORKDIR /root
ENTRYPOINT [ "sh", "startService.sh" ]
CMD [ "-it", "-d"]