#!/bin/sh
set -e

mkdir -p /var/log/mysql /run/mysqld
touch /var/log/mysql/error.log /var/log/mysql/general.log /var/log/mysql/slow.log
chown -R mysql:mysql /var/log/mysql /run/mysqld /var/lib/mysql
chmod 660 /var/log/mysql/*.log
chmod 770 /var/log/mysql /run/mysqld

# Démarre MariaDB en arrière-plan
mariadbd --user=mysql --datadir=/var/lib/mysql &
pid="$!"

# Attends que MariaDB soit prêt
until mariadb-admin ping --silent; do
  sleep 1
done

# Exécute tous les scripts SQL d'init
for f in /docker-entrypoint-initdb.d/*.sql; do
  [ -f "$f" ] && echo "Running $f" && mariadb < "$f"
done

# Arrête MariaDB temporaire
kill "$pid"
wait "$pid"

exec "$@"