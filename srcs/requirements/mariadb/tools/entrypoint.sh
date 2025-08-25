#!/bin/sh
set -e

# Lire les secrets
if [ -f /run/secrets/db_root_password ]; then
  export MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
fi
if [ -f /run/secrets/db_password ]; then
  export MYSQL_PASSWORD=$(cat /run/secrets/db_password)
fi

# Creation du dossier pour le socket + droit necessaire
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chmod 770 /run/mysqld

# Configuration de la base de données
if [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "Initialisation de la db MariaDB..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Démarrage de MariaDB en arrière-plan
mariadbd --user=mysql --datadir=/var/lib/mysql & pid="$!"

# Attente de MariaDB soit prêt
until mariadb-admin ping --silent; do
  sleep 1
done

# Création du fichier SQL pour Wordpress
cat > /tmp/init_dynamic.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Exécution du script SQL dynamique
echo "Execution du script SQL..."
mariadb < /tmp/init_dynamic.sql

kill "$pid"
wait "$pid"

# Si aucun argument, démarre MariaDB en foreground
if [ $# -eq 0 ]; then
  exec mariadbd --user=mysql --datadir=/var/lib/mysql
else
  exec "$@"
fi
