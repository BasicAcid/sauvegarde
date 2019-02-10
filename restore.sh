#! /bin/bash

# Warning: this script first delete every data under the /nextcloud directory

sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --on

rsync -Aavxziptgo backup:/root/backup david@nyxcloud:/var/www/nextcloud/

# Drop previous database
mysql -u root -proot -e "DROP DATABASE nextcloud"

# Create new database
mysql -u root -proot -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import data from backup
mysql -u root -proot nextcloud < nextcloud-sqlbkp.bak

# Turn maintenance mode OFF
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:mode --off

# update the systems data-fingerprint after a backup is restored
sudo -u www-data php /var/www/html/nextcloud/occ maintenance:data-fingerprint

# rescan files
sudo -u www-data php /var/www/html/nextcloud/occ files:scan --all

# cleanup files
sudo -u www-data php /var/www/html/nextcloud/occ files:cleanup
