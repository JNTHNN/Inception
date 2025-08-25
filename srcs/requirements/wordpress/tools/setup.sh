#!/bin/sh
set -e

# Lire les secrets
if [ -f /run/secrets/db_password ]; then
  export WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/credentials ]; then
  export WORDPRESS_ADMIN_NAME=$(cat /run/secrets/credentials)
fi
if [ -f /run/secrets/wp_admin_password ]; then
  export WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_user_password ]; then
  export WORDPRESS_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
fi

# Attendre que la DB soit prête
until mariadb -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" 2>/dev/null; do
  echo "Attente de MariaDB..."
  sleep 2
done

# Installer WP-CLI
if ! command -v wp >/dev/null; then
  echo "Installation WP-CLI..."
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp
fi

# Télécharger WordPress
if [ ! -f wp-settings.php ]; then
  echo "Téléchargement de WordPress..."
  curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz
  tar -xzf wordpress.tar.gz --strip-components=1
  rm wordpress.tar.gz
fi

# Générer wp-config.php
if [ ! -f wp-config.php ]; then
  echo "Génération de wp-config.php..."
  wp config create \
    --dbname="$WORDPRESS_DB_NAME" \
    --dbuser="$WORDPRESS_DB_USER" \
    --dbpass="$WORDPRESS_DB_PASSWORD" \
    --dbhost="$WORDPRESS_DB_HOST" \
    --allow-root
fi

# Installer WordPress
if ! wp core is-installed --allow-root; then
  echo "Installation WordPress..."
  wp core install \
    --url="https://$WORDPRESS_DOMAIN_NAME" \
    --title="$WORDPRESS_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_NAME" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  echo "Creation User WordPress..."
  wp user create "$WORDPRESS_USER_NAME" "$WORDPRESS_USER_EMAIL" \
    --role=contributor \
    --user_pass="$WORDPRESS_USER_PASSWORD" \
    --allow-root
fi

exec "$@"