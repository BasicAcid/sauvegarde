#! /bin/bash

sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on

sudo rsync -avxziptgo /var/www/nextcloud/ root@192.168.33.201:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%w`/

sudo mysqldump --single-transaction -u root nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%w`.bak

sudo rsync -avxziptgo /root/sqlbck/ root@192.168.33.201:/root/backups/nextcloud/

sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
