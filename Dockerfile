FROM php:7.2-fpm

RUN apt-get update || true && \
    sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list 2>/dev/null || true && \
    sed -i 's/security.debian.org/archive.debian.org/g' /etc/apt/sources.list 2>/dev/null || true && \
    sed -i '/jessie-updates/d' /etc/apt/sources.list 2>/dev/null || true && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99no-check-valid-until && \
    apt-get update && apt-get install -y \
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
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql zip gd

RUN mkdir -p /usr/local/lib \
    && wget -q https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xzf ioncube_loaders_lin_x86-64.tar.gz -C /usr/local/lib ioncube/ioncube_loader_lin_7.2.so \
    && rm ioncube_loaders_lin_x86-64.tar.gz

RUN echo "zend_extension=/usr/local/lib/ioncube/ioncube_loader_lin_7.2.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && echo "allow_url_fopen=On" >> /usr/local/etc/php/conf.d/99-custom.ini

COPY default /etc/nginx/sites-available/default
RUN rm -f /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/

RUN mkdir -p /var/www/html /var/log/nginx /var/cache/nginx /var/run

COPY --chown=www-data:www-data . /var/www/html

RUN chmod -R 755 /var/www/html && \
    chmod -R 777 /var/www/html/application/cache /var/www/html/application/logs 2>/dev/null || true

EXPOSE 80

CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
