FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-curl \
    php7.4-gd \
    php7.4-intl \
    php7.4-mbstring \
    php7.4-soap \
    php7.4-xml \
    php7.4-zip \
    curl \
    wget \
    mariadb-client \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI for automated WordPress configuration
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php /var/www/wordpress && \
    chown -R www-data:www-data /run/php /var/www/wordpress

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/wordpress.sh /usr/local/bin/wordpress.sh
RUN chmod +x /usr/local/bin/wordpress.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress.sh"]
