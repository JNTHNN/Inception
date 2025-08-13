#!/bin/sh
set -e

mkdir -p /var/log/mysql /run/mysqld
touch /var/log/mysql/error.log /var/log/mysql/general.log /var/log/mysql/slow.log
chown -R mysql:mysql /var/log/mysql /run/mysqld /var/lib/mysql
chmod 660 /var/log/mysql/*.log
chmod 770 /var/log/mysql /run/mysqld

exec "$@"