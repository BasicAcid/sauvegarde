#! /bin/bash

NEXTCLOUD_DIR="/var/www/html/nextcloud"

sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

sudo rsync -Aavxziptgo $NEXTCLOUD_DIR/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

sudo mysqldump --single-transaction -u root -proot nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

sudo rsync -Aavxziptgo /root/sqlbck/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

rm /root/sqlbck/*

sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off
