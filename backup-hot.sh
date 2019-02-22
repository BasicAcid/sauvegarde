#! /bin/bash

# Same as backup.sh, except this one doesn't use maintenance mode

NEXTCLOUD_DIR="/var/www/html/nextcloud"
BCK_HOST="backup"

# Syncronize with BCK_HOST server, preserving labels and setting a dierctory name based on the current week
sudo rsync -Aavxziptgo $NEXTCLOUD_DIR/ $BCK_HOST:/root/nextcloud_`date +%Y-%m-%W`/

# Dump the database Under a temporary location
sudo mysqldump --single-transaction -u root -proot nextcloud > /root/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

# Syncronize the dump with the BCK_HOST server
sudo rsync -Aavxziptgo /root/*.bak $BCK_HOST:/root/nextcloud_`date +%Y-%m-%W`/

# Delete the local dump
rm /root/*.bak
