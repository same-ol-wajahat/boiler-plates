# syntax=docker/dockerfile:1.3

FROM php:7.4-cli-alpine AS php-builder
WORKDIR /app

RUN apk update --no-cache \
    && apk add --no-cache \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libzip-dev \
    zlib-dev

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd zip

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

COPY . .
RUN composer update \
    && composer dump-autoload

FROM node:12-alpine AS node-builder
WORKDIR /app
COPY package.json .
RUN apk update --no-cache \
        && apk upgrade --available --no-cache \
        && npm install

FROM php:7.4-apache

WORKDIR /srv/app

# Copy Apache and PHP configuration
COPY apache/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY apache/mpm_prefork.conf /etc/apache2/mods-available/mpm_prefork.conf
COPY apache/apache2.conf /etc/apache2/apache2.conf
COPY apache/php.ini-production "$PHP_INI_DIR"/php.ini
COPY apache/ports.conf /etc/apache2/ports.conf

RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && node -v && npm -v

RUN apt-get update -y \
    && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype-dev \
    libzip-dev \
    unzip \
    nano

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql opcache gd zip \
    && docker-php-ext-configure opcache \
    && apt-get autoremove -y \
    && apt-get autoclean -y

COPY --from=php-builder --chown=www-data:www-data /app .
COPY --from=node-builder --chown=www-data:www-data /app .

# Securely inject PEM key using BuildKit secrets
RUN --mount=type=secret,id=private_key \
    cp /run/secrets/private_key /srv/app/private_key.pem && \
    chmod 600 /srv/app/private_key.pem

EXPOSE 8000

ENTRYPOINT ["/bin/bash", "entrypoint/entrypoint.sh"]
