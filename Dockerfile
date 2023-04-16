FROM php:8.1.18-zts-alpine3.17 AS php-builder

FROM composer:lts AS composer-builder

WORKDIR /app

COPY ./composer.json ./

RUN composer install

COPY ./ ./

RUN composer dump-autoload

RUN php artisan route:clear

RUN php artisan cache:clear

RUN php artisan optimize:clear

RUN docker-php-ext-install pdo pdo_pgsql

FROM nginx:stable-alpine

COPY --from=php-builder /app /usr/share/nginx/html

COPY ./docker/nginx/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080