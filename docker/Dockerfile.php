FROM php:8.1.18-fpm-alpine3.17

ARG UID
ARG GID

ENV UID=${UID}
ENV GID=${GID}

RUN mkdir -p /var/www/html

WORKDIR /var/www/html

RUN addgroup -g ${GID} --system laravel
RUN adduser -G laravel --system -D -s /bin/sh -u ${UID} laravel

RUN sed -i "s/user = www-data/user = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/group = www-data/group = laravel/g" /usr/local/etc/php-fpm.d/www.conf
RUN echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

# defined extension deps
ENV PHP_INSTALL_EXT_DEPS \
    # for zip
    libzip-dev \
    # for intl
    icu-dev \
    # for imap
    imap-dev openssl-dev \
    # for tidy
    tidyhtml-dev \
    # for gd
    freetype-dev libjpeg-turbo-dev libpng-dev

RUN apk update \
	&& apk add --no-cache \
    libzip \
    icu \
    imap c-client \
    tidyhtml \
    freetype libpng libjpeg-turbo \
    && apk add --update --no-cache --virtual .build-ext-deps $PHP_INSTALL_EXT_DEPS \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure imap --with-imap --with-imap-ssl \
    && docker-php-ext-configure opcache --enable-opcache \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_pgsql pdo_mysql zip intl imap tidy pcntl opcache bcmath gd \
    && apk del .build-ext-deps

RUN apk --update add --virtual build-dependencies build-base openssl-dev autoconf \
  && pecl install mongodb \
  && docker-php-ext-enable mongodb \
  && apk del build-dependencies build-base openssl-dev autoconf \
  && rm -rf /var/cache/apk/*

RUN if [ "${DOCKER_PHP_ENABLE_LDAP}" != "off" ]; then \
        apk add --update --no-cache \
            libldap && \
        apk add --update --no-cache --virtual .docker-php-ldap-dependancies \
            openldap-dev && \
        docker-php-ext-configure ldap && \
        docker-php-ext-install ldap && \
        apk del .docker-php-ldap-dependancies && \
        php -m; \
    else \
        echo "Skip ldap support"; \
    fi

CMD ["php-fpm", "-y", "/usr/local/etc/php-fpm.conf", "-R"]
