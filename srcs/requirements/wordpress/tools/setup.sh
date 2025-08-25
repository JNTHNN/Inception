#!/bin/sh
set -e

# Lire les secrets depuis les fichiers si disponibles
if [ -f /run/secrets/db_password ]; then
  export WORDPRESS_DB_PASSWORD=$(cat /run/secrets/db_password)
fi
if [ -f /run/secrets/wp_admin_password ]; then
  export WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
fi
if [ -f /run/secrets/wp_user_password ]; then
  export WORDPRESS_USER_PASSWORD=$(cat /run/secrets/wp_user_password)
fi
if [ -f /run/secrets/wp_auth_key ]; then
  export WORDPRESS_AUTH_KEY=$(cat /run/secrets/wp_auth_key)
fi
if [ -f /run/secrets/wp_secure_auth_key ]; then
  export WORDPRESS_SECURE_AUTH_KEY=$(cat /run/secrets/wp_secure_auth_key)
fi
if [ -f /run/secrets/wp_logged_in_key ]; then
  export WORDPRESS_LOGGED_IN_KEY=$(cat /run/secrets/wp_logged_in_key)
fi
if [ -f /run/secrets/wp_nonce_key ]; then
  export WORDPRESS_NONCE_KEY=$(cat /run/secrets/wp_nonce_key)
fi
if [ -f /run/secrets/wp_auth_salt ]; then
  export WORDPRESS_AUTH_SALT=$(cat /run/secrets/wp_auth_salt)
fi
if [ -f /run/secrets/wp_secure_auth_salt ]; then
  export WORDPRESS_SECURE_AUTH_SALT=$(cat /run/secrets/wp_secure_auth_salt)
fi
if [ -f /run/secrets/wp_logged_in_salt ]; then
  export WORDPRESS_LOGGED_IN_SALT=$(cat /run/secrets/wp_logged_in_salt)
fi
if [ -f /run/secrets/wp_nonce_salt ]; then
  export WORDPRESS_NONCE_SALT=$(cat /run/secrets/wp_nonce_salt)
fi

# Attendre que la DB soit prête
until mariadb -h "$WORDPRESS_DB_HOST" -u "$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" "$WORDPRESS_DB_NAME" -e "SELECT 1;" 2>/dev/null; do
  echo "Waiting for MariaDB..."
  sleep 2
done

# Installer WP-CLI si besoin
if ! command -v wp >/dev/null; then
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp
fi

cd /home/jgasparo/data/www/wordpress

# Installer WordPress si ce n'est pas déjà fait
if ! wp core is-installed --allow-root; then
  wp core install \
    --url="https://$WORDPRESS_DOMAIN_NAME" \
    --title="$WORDPRESS_TITLE" \
    --admin_user="$WORDPRESS_ADMIN_USER" \
    --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
    --admin_email="$WORDPRESS_ADMIN_EMAIL" \
    --skip-email \
    --allow-root

  wp user create correcteur correcteur@student.s19.be \
    --role=contributor \
    --user_pass="$WORDPRESS_USER_PASSWORD" \
    --allow-root

fi

exec "$@"