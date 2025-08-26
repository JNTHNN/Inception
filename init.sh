#!/bin/bash
set -e

echo "Création des volumes..."

mkdir -p /home/jgasparo/data/www/wordpress
mkdir -p /home/jgasparo/data/mariadb

# Définir les permissions appropriées
chmod 755 /home/jgasparo/data
chmod 755 /home/jgasparo/data/www/wordpress
sudo chown -R 999:999 /home/jgasparo/data/mariadb
sudo chmod -R 755 /home/jgasparo/data/mariadb

echo "Volumes créés avec succès !"

