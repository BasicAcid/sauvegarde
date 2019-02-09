#! /bin/bash

sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on

sudo rsync -avxziptgo /var/www/html/nextcloud/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

sudo mysqldump --single-transaction -u root -proot nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

sudo rsync -avxziptgo /root/sqlbck/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

rm /root/sqlbck/*

sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off
