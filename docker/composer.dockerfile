FROM composer:lts AS composer-builder

WORKDIR /app

COPY ../composer.json ./

RUN composer install

COPY ../ ./

RUN composer dump-autoload