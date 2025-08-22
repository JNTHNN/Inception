#!/bin/sh
set -e

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