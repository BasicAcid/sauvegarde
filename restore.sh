#! /bin/bash

# =======================================================================================================================
# WARNING: this script first delete every data under the /nextcloud directory, be sure to make a backup before using it
# =======================================================================================================================

NEXTCLOUD_DIR="/var/www/html/nextcloud"
BCK_HOST="backup"

if ssh backup '[ ! -d /root/nextcloud_* ]'
then
    echo "No backup present on the server, please make a backup before using this script" >&2
    exit 1
fi

# I also like to live dangerously
rm -r $NEXTCLOUD_DIR

# Drop previous database
mysql -u root -proot -e "DROP DATABASE nextcloud"

# get last backup
LAST_DIR=$(ssh backup "ls -td */ /root/ | head -n 1")

# sync
rsync -Aavxziptgo $BCK_HOST:/root/$LAST_DIR /var/www/html/

# rename into "nextcloud"
mv /var/www/html/$LAST_DIR $NEXTCLOUD_DIR

# Turn maintenance mode ON
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

# Create new database
mysql -u root -proot -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import data from backup
mysql -u root -proot nextcloud < $NEXTCLOUD_DIR/nextcloud-sqlbkp_*

# Delete dump
rm $NEXTCLOUD_DIR/nextcloud-sqlbkp_*

# Turn maintenance mode OFF
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off

# update the systems data-fingerprint after a backup is restored
sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:data-fingerprint

# rescan files
sudo -u www-data php $NEXTCLOUD_DIR/occ files:scan --all

# cleanup files
sudo -u www-data php $NEXTCLOUD_DIR/occ files:cleanup
