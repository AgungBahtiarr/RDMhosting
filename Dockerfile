FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    nginx \
    curl \
    wget \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libmariadb-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd

RUN mkdir -p /usr/local/lib \
    && wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xzf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local/lib ioncube/ioncube_loader_lin_8.3.so \
    && rm ioncube_loaders_lin_x86-64.tar.gz

RUN echo "zend_extension=/usr/local/lib/ioncube/ioncube_loader_lin_8.3.so" > /usr/local/etc/php/conf.d/ioncube.ini \
    && echo "allow_url_fopen=On" >> /usr/local/etc/php/conf.d/custom.ini

COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /var/www/html /var/log/nginx /var/cache/nginx /var/run \
    && touch /var/run/nginx.pid \
    && chown -R www-data:www-data /var/www/html

RUN chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/application/cache /var/www/html/application/logs 2>/dev/null || true

COPY --chown=www-data:www-data . /var/www/html

EXPOSE 80

CMD php-fpm & nginx -g "daemon off;"
