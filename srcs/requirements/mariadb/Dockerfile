FROM alpine:3.22.0

RUN apk update && \
    apk add --no-cache mariadb mariadb-client && \
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

COPY conf/my.cnf /etc/my.cnf
COPY tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]
CMD ["mariadbd", "--user=mysql"]