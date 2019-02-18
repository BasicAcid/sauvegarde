#! /bin/bash

NEXTCLOUD_DIR="/var/www/html/nextcloud"

RSYNC_COMMAND="rsync -Aavxziptgo"

while getopts "brh" opt; do
    case $opt in
	b)
	    # Turn maintenance mode ON
	    sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

	    # Syncronize with backup server, preserving labels and setting a dierctory name based on the current week
	    sudo $RSYNC_COMMAND $NEXTCLOUD_DIR/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

	    # Dump the database Under a temporary location
	    sudo mysqldump --single-transaction -u root -proot nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

	    # Syncronize the dump with the backup server
	    sudo $RSYNC_COMMAND /root/sqlbck/ backup:/root/backups/nextcloud/nextcloud_`date +%Y-%m-%W`/

	    # Delete the local dump
	    rm /root/sqlbck/*

	    # Turn maintenance mode OF
	    sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off

	    exit
	    ;;

	r)
	    # ===================================================================================================
	    # WARNING: delete every data under the /nextcloud directory, be sure to make a backup before using it
	    # ===================================================================================================

	    rm -r $NEXTCLOUD_DIR

	    # Drop previous database
	    mysql -u root -proot -e "DROP DATABASE nextcloud"

	    # get last backup
	    LAST_DIR=$(ssh backup "ls -t /root/backups/nextcloud/ | head -n 1")

	    # Restore last backup
	    $RSYNC_COMMAND backup:/root/backups/nextcloud/$LAST_DIR /var/www/html/

	    # Change backup name to default
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

	    exit
	    ;;
	h)
	    echo "Usage: nxbackup.sh [OPTION...]"
	    echo ""
	    echo "  -b, make a backup"
	    echo "  -r, restore a backup" >&2
	    ;;
	\?)
	    echo "Invalid option: -$OPTARG" >&2
	    ;;
    esac
done
