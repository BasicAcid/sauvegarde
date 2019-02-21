#! /bin/bash

# Same as backup.sh, except this one doesn't use maintenance mode

NEXTCLOUD_DIR="/var/www/html/nextcloud"

# Syncronize with backup server, preserving labels and setting a dierctory name based on the current week
sudo rsync -Aavxziptgo $NEXTCLOUD_DIR/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

# Dump the database Under a temporary location
sudo mysqldump --single-transaction -u root -proot nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

# Syncronize the dump with the backup server
sudo rsync -Aavxziptgo /root/sqlbck/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

# Delete the local dump
rm /root/sqlbck/*
