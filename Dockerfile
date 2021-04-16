FROM ubuntu:latest
MAINTAINER Mark Christopher West<markchristopherwest@gmail.com>
ENV DEBIAN_FRONTEND noninteractive
# Install basics
RUN apt update
RUN apt install -y software-properties-common vim && \
add-apt-repository ppa:ondrej/php && apt update
RUN apt install -y curl
# Install PHP 8.0
RUN apt install -y apache2 php8.0 php8.0-mysql php8.0-mcrypt php8.0-cli php8.0-gd php8.0-curl libapache2-mod-php libapache2-mod-fcgid
# Enable apache mods.
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php8.0
RUN a2enmod rewrite
# Manually set up the apache environment variables
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
# Create directories for source code
RUN mkdir -p /var/www/home
# Expose apache.
EXPOSE 80
EXPOSE 8080
EXPOSE 443
EXPOSE 3306
# Update the default apache site with the config we created.
ADD apache-config.conf /etc/apache2/sites-enabled/000-default.conf
# By default start up apache in the foreground, override with /bin/bash for interative.
CMD /usr/sbin/apache2ctl -D FOREGROUND