# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables to non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Update and install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    git \
    apt-transport-https \
    ca-certificates \
    curl \
    apache2 \
    software-properties-common

# Add PHP repository and install PHP 7.3 with necessary extensions
RUN add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install -y \
    php7.3 \
    libapache2-mod-php7.3 \
    php7.3-common \
    php7.3-mysql \
    php7.3-ldap \
    php7.3-json \
    php7.3-curl \
    php7.3-zip \
    php7.3-xml \
    php7.3-mbstring

# Enable Apache mods and PHP
RUN a2enmod php7.3 && \
    service apache2 restart
WORKDIR  /var/www/html
# Clone openSIS-Classic repository
RUN git clone https://github.com/OS4ED/openSIS-Classic.git  -b ver7.4 openSIS
RUN chown -R www-data:www-data  openSIS

# Copy startup script and grant execution rights
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Start services
CMD ["/start.sh"]
