FROM php:8.1.18-fpm

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
RUN groupadd -g 1000 www
RUN useradd -u 1000 -ms /bin/bash -g www www

# Set working directory
WORKDIR /var/www/

# Copy file composer.json dan composer.lock ke dalam container
COPY ./ ./

# Install dependencies menggunakan Composer
RUN composer install --no-scripts --no-progress --no-interaction

# Autoload Composer
RUN composer dump-autoload --optimize

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

# Copy existing application directory permissions
COPY --chown=www:www . /var/www

# Change current user to www
USER www

CMD ["php-fpm"]
