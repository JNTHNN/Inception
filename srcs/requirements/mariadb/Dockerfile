FROM alpine:3.22.0

RUN apk update && \
    apk add --no-cache mariadb mariadb-client && \
    mkdir -p /var/log/mysql

COPY conf/my.cnf /etc/my.cnf

