FROM alpine:3.22.0

RUN apk update && \
    apk add --no-cache php php-fpm php-mysqli php-json php-curl php-xml php-mbstring php-gd php-session php-opcache php-dom php-zip php-tokenizer php-ctype php-phar curl mariadb-client && \
    sed -i 's|listen = 127.0.0.1:9000|listen = 0.0.0.0:9000|' /etc/php83/php-fpm.d/www.conf && \
    echo "clear_env = no" >> /etc/php83/php-fpm.d/www.conf && \
    mkdir -p /home/jgasparo/data/www/wordpress && \
    curl -o /home/jgasparo/data/www/wordpress/wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf /home/jgasparo/data/www/wordpress/wordpress.tar.gz --strip-components=1 -C /home/jgasparo/data/www/wordpress && \
    rm /home/jgasparo/data/www/wordpress/wordpress.tar.gz

WORKDIR /home/jgasparo/data/www/wordpress

COPY tools/setup.sh /setup.sh

RUN chmod +x /setup.sh

EXPOSE 9000

ENTRYPOINT ["/setup.sh"]
CMD ["php-fpm83", "-F", "-y", "/etc/php83/php-fpm.conf"]
