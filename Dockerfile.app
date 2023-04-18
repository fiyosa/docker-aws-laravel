FROM php:8.1.18-fpm

# add composer to image app
COPY --from=composer:2.5.5 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

# add nodejs to image app
COPY --from=node:14.21.3-slim /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node:14.21.3-slim /usr/local/bin/node /usr/local/bin/node
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm

# Install dependensi PHP dan PHP-FPM
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libpq-dev

RUN docker-php-ext-install pdo pdo_pgsql

# Set working directory
WORKDIR /var/www/html

# Copy file composer.json dan composer.lock ke dalam container
COPY ./ ./

# Install dependencies menggunakan Composer
RUN composer install --no-scripts --no-autoloader --no-progress --no-interaction

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

# Autoload Composer
RUN composer dump-autoload --optimize