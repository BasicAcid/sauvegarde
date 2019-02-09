#! /bin/bash

# Warning: this script first delete every data under the /nextcloud directory

# Turn maintenance mode ON
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --on

rsync -Aax david@trinity:/home/david/nextcloud-dirbkp/ david@nyxcloud:/var/www/nextcloud/

# Drop previous database
mysql -u root -p[password] -e "DROP DATABASE nextcloud"

# Create new database
mysql -u root -p[password] -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# Import data from backup
mysql -h [server] -u [username] -p[password] [db_name] < nextcloud-sqlbkp.bak

# Turn maintenance mode OFF
sudo -u www-data php /var/www/nextcloud/occ maintenance:mode --off

# update the systems data-fingerprint after a backup is restored
sudo -u www-data php /var/www/nextcloud/occ maintenance:data-fingerprint

# rescan files
sudo -u www-data php /var/www/nextcloud/occ files:scan --all

# cleanup files
sudo -u www-data php /var/www/nextcloud/occ files:cleanup
