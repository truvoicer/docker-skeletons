#Download base image ubuntu 20.04
FROM ubuntu:20.04

# LABEL about the custom image
LABEL maintainer="michael.toriola@finixio.com"
LABEL version="0.1"
LABEL description="Custom docker image for php and nginx"

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update

# Install nginx, php-fpm and supervisord from ubuntu repository
RUN apt install -y zip git unzip curl supervisor vim nano build-essential nginx
RUN apt install -y php7.4 php7.4-fpm php7.4-curl php7.4-mysql php7.4-xml php7.4-zip php7.4-mbstring php7.4-cli mysql-client

RUN rm -rf /var/lib/apt/lists/*
RUN apt clean

#Define the ENV variable
ENV nginx_avail /etc/nginx/sites-available
ENV nginx_enabled /etc/nginx/sites-enabled
ENV supervisor_conf /etc/supervisor/supervisord.conf

# Enable PHP-fpm on nginx virtualhost configuration

#Copy supervisor configuration
COPY ./supervisord.conf ${supervisor_conf}

#Remove default NGINX vhosts
RUN rm ${nginx_enabled}/default
RUN rm ${nginx_avail}/default

#Copy NGINX vhosts
COPY ./nginx/default.conf ${nginx_avail}/default.conf
RUN ln -s "${nginx_avail}/default.conf" "${nginx_enabled}/default.conf"

COPY ./start.sh /start.sh
RUN chmod +x /start.sh

COPY ./ /var/www/html/

WORKDIR /var/www/html

VOLUME ["/etc/nginx/sites-available", "/etc/nginx/sites-enabled", "/var/log/nginx"]

#Web docs
RUN mkdir -p /run/php
RUN chown -R www-data:www-data /run/php

# Volume configuration
# Copy start.sh script and define default command for the container
ENTRYPOINT ["/bin/sh", "/start.sh"]

# Expose Port for the Application
EXPOSE 80 443
