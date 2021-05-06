FROM ubuntu:20.04


LABEL maintainer="mcw@markchristopherwest.com"
LABEL description="Apache / PHP for dev"

ENV DEBIAN_FRONTEND noninteractive

# Install basics
RUN apt-get update -y
RUN apt-get install -y software-properties-common 
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update -y

# Install PHP 8.0
RUN apt install -y apache2 php8.0 php8.0-mysql php8.0-mcrypt php8.0-cli php8.0-gd php8.0-curl libapache2-mod-php libapache2-mod-fcgid
# Enable apache mods.
RUN a2dismod mpm_event
RUN a2enmod mpm_prefork
RUN a2enmod php8.0
RUN a2enmod rewrite

RUN apt-get install -y php8.0-common \
php8.0-cli \
php8.0-bz2 \
php8.0-curl \
php8.0-intl \
php8.0-mysql \
php8.0-readline \ 
php8.0-xml \
php8.0-pcov \
php8.0-xdebug \
libapache2-mod-php8.0 \
libsasl2-modules \
postfix \
mailutils \
git \
nano \
tree \
vim \
curl \
ftp  
RUN pecl install xdebug; \
    docker-php-ext-enable xdebug\
        { \
            echo "[xdebug]"; \
            echo "zend_extension=xdebug.so"; \
            echo "xdebug.profiler_enable=1"; \
            echo "xdebug.remote_enable=1"; \
            echo "xdebug.remote_handler=dbgp"; \
            # echo "xdebug.remote_mode=debug" \
            echo "xdebug.client_host=host.docker.internal"; \
            echo "xdebug.remote_port=9000"; \
            echo "xdebug.start_with_request=yes"; \
            echo "xdebug.remote_connect_back=1";\
            echo "xdebug.idekey=PHPSTORM" \
        } >> /etc/php/8.0/mods-available/xdebug.ini; \
        phpenmod -v 8.0 xdebug; 



# to be able to use "nano" with shell on "docker exec -it [CONTAINER ID] bash"
ENV TERM xterm


# Enable apache mods.

# Update the PHP.ini file, enable <? ?> tags and quieten logging.
# RUN sed -i "s/short_open_tag = Off/short_open_tag = On/" /etc/php/8.0/apache2/php.ini
RUN sed -i 's/^error_reporting = .*/error_reporting = E_ALL /' /etc/php/8.0/apache2/php.ini
RUN sed -i "s/display_errors = Off/display_errors = On/g" /etc/php/8.0/apache2/php.ini


# without the following line we get "AH00558: apache2: Could not reliably determine the server's fully qualified domain name"
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# autorise .htaccess files
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# set perms
RUN chgrp -R www-data /var/www
RUN find /var/www -type d -exec chmod 775 {} +
RUN find /var/www -type f -exec chmod 664 {} +

# Manually set up the apache environment variables
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV LOG_STDOUT true
ENV LOG_STDERR true
ENV LOG_LEVEL debug
ENV ALLOW_OVERRIDE All
ENV DATE_TIMEZONE America/Los_Angeles
ENV DB_HOST mysql
ENV VIRTUAL_HOST markchristopherwest.com
ENV PHP_EXTENSION_XDEBUG 1

COPY info.php /var/www/html/index.php
COPY runner.sh /usr/sbin/

RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN chown -R root:root /var/www/html
RUN touch /var/lib/php/session
RUN chown -R root:root /var/lib/php/session
RUN chmod +x /usr/sbin/runner.sh


VOLUME /var/www/html
# VOLUME /var/log/httpd
# VOLUME /var/lib/mysql
# VOLUME /var/log/mysql
# VOLUME /etc/apache2

EXPOSE 80 31080
EXPOSE 443 31443
EXPOSE 3306 30306
EXPOSE 9000 9000

RUN apt autoclean
RUN apt --purge autoremove

CMD ["/usr/sbin/runner.sh"]
