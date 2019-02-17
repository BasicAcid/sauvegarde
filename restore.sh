#! /bin/bash

# =======================================================================================================================
# WARNING: this script first delete every data under the /nextcloud directory, be sure to have a backup before using it
# =======================================================================================================================

NEXTCLOUD_DIR="/var/www/html/nextcloud"

rm -r $NEXTCLOUD_DIR/*

# Drop previous database
mysql -u root -proot -e "DROP DATABASE nextcloud"

# get last modified directory
LAST_DIR=ssh backup "ls -t /root/backups/nextcloud/ | head -n 1"

rsync -Aavxziptgo backup:/root/backups/nextcloud/$LAST_DIR $NEXTCLOUD_DIR/

mv /root/backups/nextcloud/$LAST_DIR/* /root/backups/nextcloud/

rm -r /root/backups/nextcloud/$LAST_DIR

sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

# Create new database
mysql -u root -proot -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import data from backup
mysql -u root -proot nextcloud < $NEXTCLOUD_DIR/nextcloud-sqlbkp_*

# Turn maintenance mode OFF
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off

# update the systems data-fingerprint after a backup is restored
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:data-fingerprint

# rescan files
sudo -u www-data php $NEXTCLOUD_DIR/occ files:scan --all

# cleanup files
sudo -u www-data php $NEXTCLOUD_DIR/occ files:cleanup
