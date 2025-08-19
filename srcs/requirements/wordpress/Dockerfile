FROM alpine:3.22.0

RUN apk update && \
    apk add --no-cache php php-fpm php-mysqli php-json php-curl php-xml php-mbstring php-gd php-session php-opcache php-dom php-zip php-tokenizer php-ctype curl

WORKDIR /home/jgasparo/data/www/wordpress

RUN curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz && \
    tar -xzf wordpress.tar.gz --strip-components=1 && \
    rm wordpress.tar.gz

EXPOSE 9000

CMD ["php-fpm83", "-F", "-y", "/etc/php83/php-fpm.conf"]
