FROM debian:bullseye

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx.sh /usr/local/bin/nginx.sh
RUN chmod +x /usr/local/bin/nginx.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx.sh"]
