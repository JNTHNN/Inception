#!/bin/bash

# Script d'initialisation pour créer les dossiers de données
echo "Création des dossiers de données..."

# Créer les dossiers de données s'ils n'existent pas
mkdir -p /home/jgasparo/data/www/wordpress
mkdir -p /home/jgasparo/data/mariadb

# Définir les permissions appropriées
chmod 755 /home/jgasparo/data
chmod 755 /home/jgasparo/data/www/wordpress
sudo chown -R 999:999 /home/jgasparo/data/mariadb
sudo chmod -R 755 /home/jgasparo/data/mariadb

echo "Dossiers de données créés avec succès !"

