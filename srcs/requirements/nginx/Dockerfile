FROM alpine:3.22.0

RUN apk update && \
    apk add --no-cache nginx && \
    mkdir -p /run/nginx && \
    apk add --no-cache openssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -subj "/C=BE/ST=Bruxelles/L=Bruxelles/O=campus19/OU=IT/CN=jgasparo.42.fr/emailAddress=jgasparo@student.s19.be" \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt

EXPOSE 443

COPY conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]