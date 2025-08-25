#!/bin/sh
set -e

# Lire les secrets depuis les fichiers si disponibles
if [ -f /run/secrets/db_root_password ]; then
  export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/db_password ]; then
  export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

mkdir -p /var/log/mysql /run/mysqld
touch /var/log/mysql/error.log /var/log/mysql/general.log /var/log/mysql/slow.log
chown -R mysql:mysql /var/log/mysql /run/mysqld /var/lib/mysql
chmod 660 /var/log/mysql/*.log
chmod 770 /var/log/mysql /run/mysqld

# Configurer la base de données si elle n'existe pas
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initializing MariaDB database..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Démarre MariaDB en arrière-plan
mariadbd --user=mysql --datadir=/var/lib/mysql &
pid="$!"

# Attends que MariaDB soit prêt
until mariadb-admin ping --silent; do
  sleep 1
done

# Créer le fichier SQL d'initialisation avec les vraies valeurs
cat > /tmp/init_dynamic.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Exécute le script SQL dynamique
echo "Running dynamic initialization script"
mariadb < /tmp/init_dynamic.sql

# Exécute tous les autres scripts SQL d'init
for f in /docker-entrypoint-initdb.d/*.sql; do
  [ -f "$f" ] && echo "Running $f" && mariadb < "$f"
done

# Arrête MariaDB temporaire
kill "$pid"
wait "$pid"

exec "$@"