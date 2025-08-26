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

# Forcer l'usage du mot de passe pour root
cat > /tmp/force_root_password.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" < /tmp/force_root_password.sql

# Définir le mot de passe root explicitement
cat > /tmp/set_root_password.sql <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" < /tmp/set_root_password.sql

# Création + exec du fichier SQL pour Wordpress
cat > /tmp/init_dynamic.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

echo "Execution du script SQL..."
mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" < /tmp/init_dynamic.sql

kill "$pid"
wait "$pid"

# Si aucun argument, démarre MariaDB en foreground
if [ $# -eq 0 ]; then
  exec mariadbd --user=mysql --datadir=/var/lib/mysql
else
  exec "$@"
fi
