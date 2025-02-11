FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get install -yqq software-properties-common > /dev/null
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get install -yqq nginx git unzip \
    php8.2-fpm php8.2-mysql php8.2-xml php8.2-mbstring php8.2-intl php8.2-dev  php8.2-curl > /dev/null

COPY deploy/conf/* /etc/php/8.2/fpm/

ADD ./ /nette
WORKDIR /nette

#ENV NETTE_DIR="/nette/src"

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN composer install --optimize-autoloader --classmap-authoritative --no-dev --quiet

RUN if [ $(nproc) = 2 ]; then sed -i "s|pm.max_children = 1024|pm.max_children = 512|g" /etc/php/8.2/fpm/php-fpm.conf ; fi;

RUN chmod -R 777 /nette

EXPOSE 8080

CMD service php8.2-fpm start && \
    nginx -c /nette/deploy/nginx.conf 2>&1 > /dev/stderr
