FROM alpine:3.9

# ARG BUILD_DATE
# ARG VCS_REF

# LABEL org.label-schema.build-date=$BUILD_DATE \
#       org.label-schema.vcs-url="https://github.com/phpearth/docker-php.git" \
#       org.label-schema.vcs-ref=$VCS_REF \
#       org.label-schema.schema-version="1.0" \
#       org.label-schema.vendor="PHP.earth" \
#       org.label-schema.name="docker-php" \
#       org.label-schema.description="Docker For PHP Developers - Docker image with PHP 7, Apache, and Alpine" \
#       org.label-schema.url="https://github.com/phpearth/docker-php"

# PHP_INI_DIR to be symmetrical with official php docker image
ENV PHP_INI_DIR /etc/php/7

# When using Composer, disable the warning about running commands as root/super user
ENV COMPOSER_ALLOW_SUPERUSER=1

# Persistent runtime dependencies
ARG DEPS="\
        php7 \
        php7-phar \
        php7-bcmath \
        php7-calendar \
        php7-mbstring \
        php7-exif \
        php7-ftp \
        php7-openssl \
        php7-zip \
        php7-sysvsem \
        php7-sysvshm \
        php7-sysvmsg \
        php7-shmop \
        php7-sockets \
        php7-zlib \
        php7-bz2 \
        php7-curl \
        php7-simplexml \
        php7-xml \
        php7-opcache \
        php7-dom \
        php7-xmlreader \
        php7-xmlwriter \
        php7-tokenizer \
        php7-ctype \
        php7-session \
        php7-fileinfo \
        php7-iconv \
        php7-json \
        php7-posix \
        php7-apache2 \
        curl \
        ca-certificates \
        runit \        
        openrc \
		composer \ 
        php7-gd \
        php7-pdo \
        php7-pdo_sqlite \
        php7-sqlite3 \
        git \
        apache2 \
"


RUN set -x \    
    && apk add --no-cache $DEPS \
    && php -m \
    && mkdir -p /var/www \
    && cd /var/www/ \
    && git clone https://github.com/falconchen/WebStack-Laravel.git html \
    && cd /var/www/html/public/uploads && tar czf /var/www/html/uploads.tgz . \
    && mkdir /db \
    && touch /db/webstack.sqlite 
    

COPY httpd.conf /etc/apache2/ 
COPY .env.example /var/www/html/.env 
COPY entrypoint.sh /entrypoint.sh 


RUN cd /var/www/html/ \    
    && composer install \
    && echo "APP_KEY=" >>.env \
    && php artisan key:generate \
    && php artisan migrate:refresh --seed \
    && chown -R apache:apache /var/www/html \    
    && chmod -R 755 /var/www/html \
    && chmod +x /entrypoint.sh
    
ENV WEBSTACK_DIR /var/www/html

WORKDIR /var/www/html
VOLUME /var/www/html
VOLUME /db
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]

