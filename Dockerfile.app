FROM php:8.1.18-fpm

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

# add composer to image app
COPY --from=composer:2.5.5 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# add nodejs to image app
COPY --from=node:14.21.3-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:14.21.3-slim /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libzip-dev

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Add user for laravel application
RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# Set working directory
WORKDIR /var/www

# Copy file composer.json dan composer.lock ke dalam container
COPY ./ ./

# Install dependencies menggunakan Composer
RUN composer install --no-scripts --no-progress --no-interaction

# Autoload Composer
RUN composer dump-autoload --optimize

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

CMD ["php-fpm"]
