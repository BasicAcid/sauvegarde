#! /bin/bash

NEXTCLOUD_DIR="/var/www/html/nextcloud"
BCK_HOST="backup"

# Turn maintenance mode ON
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

# Syncronize with BCK_HOST server, preserving labels and setting a dierctory name based on the current week
sudo rsync -Aavxziptgo $NEXTCLOUD_DIR/ $BCK_HOST:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

# Dump the database Under a temporary location
sudo mysqldump --single-transaction -u root -proot nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

# Syncronize the dump with the BCK_HOST server
sudo rsync -Aavxziptgo /root/sqlbck/ $BCK_HOST:/root/BCK_HOSTs/nextcloud/nextcloud_`date +%Y-%m-%W`/

# Delete the local dump
rm /root/sqlbck/*

# Turn maintenance mode OF
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off
