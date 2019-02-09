#! /bin/bash

sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on

sudo rsync -avxziptgo /var/www/nextcloud/ david@poseidon:/home/david/HDD/backups/nextcloud/nextcloud_`date +%Y-%m-%w`/

sudo mysqldump --single-transaction  -u root nextcloud > /home/david/sqlbkp/nextcloud-sqlbkp_`date +%Y-%m-%w`.bak

sudo rsync -avxziptgo /home/david/sqlbkp david@poseidon:/home/david/HDD/backups/nextcloud/

sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off
