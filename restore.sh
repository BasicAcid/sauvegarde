#! /bin/bash

# =======================================================================================================================
# WARNING: this script first delete every data under the /nextcloud directory, be sure to have a backup before using it
# =======================================================================================================================

NEXTCLOUD_DIR="/var/www/html/nextcloud"

sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

rm -r $NEXTCLOUD_DIR/*

rsync -Aavxziptgo backup:/root/backups/nextcloud/$(ls -t | head -n 1) $NEXTCLOUD_DIR/

# Drop previous database
mysql -u root -proot -e "DROP DATABASE nextcloud"

# Create new database
mysql -u root -proot -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import data from backup
mysql -u root -proot nextcloud < nextcloud-sqlbkp.bak

# Turn maintenance mode OFF
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off

# update the systems data-fingerprint after a backup is restored
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:data-fingerprint

# rescan files
sudo -u www-data php $NEXTCLOUD_DIR/occ files:scan --all

# cleanup files
sudo -u www-data php $NEXTCLOUD_DIR/occ files:cleanup
