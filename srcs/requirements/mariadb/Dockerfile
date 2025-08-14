FROM alpine:3.22.0

RUN apk update && \
    apk add --no-cache mariadb mariadb-client && \
    mariadb-install-db --user=mysql --datadir=/home/jgasparo/data/lib/mysql

COPY conf/my.cnf /etc/my.cnf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 3306

CMD ["/entrypoint.sh", "mariadbd", "--user=mysql"]

