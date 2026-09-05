#!/bin/bash
set -e

mkdir -p /etc/nginx/ssl

# Generate self-signed TLS certificates for local SSL termination if not already present
if [ ! -f /etc/nginx/ssl/inception.crt ] || [ ! -f /etc/nginx/ssl/inception.key ]; then
    echo "==> [NGINX] Generating TLSv1.2/TLSv1.3 SSL certificates for ${DOMAIN_NAME:-localhost}..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/inception.key \
        -out /etc/nginx/ssl/inception.crt \
        -subj "/C=FR/ST=IDF/L=Paris/O=42School/OU=Inception/CN=${DOMAIN_NAME:-localhost}"
    echo "==> [NGINX] SSL certificates created at /etc/nginx/ssl/."
fi

echo "==> [NGINX] Starting NGINX server on port 443..."
exec nginx -g "daemon off;"
