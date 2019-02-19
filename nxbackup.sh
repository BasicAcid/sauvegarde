#! /bin/bash

BACKUP_SERVER=backup

NEXTCLOUD_DIR="/var/www/html/nextcloud"

RSYNC_COMMAND="rsync -Aavxziptgo"

BACKUP_DIR="/root/backups"

HELP="\nUsage: nxbackup.sh [OPTION...]\n
        -b, make a backup\n
  	-r, restore a backup\n"

GREEN='\033[1;32m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Unelegant kitsch banner...
echo -e "
${PURPLE} ____ ____ __________ ____ ____ ____ ____ ____ ____
||${GREEN}N${PURPLE} |||${GREEN}X${PURPLE} |||        |||${GREEN}B${PURPLE} |||${GREEN}A${PURPLE} |||${GREEN}C${PURPLE} |||${GREEN}K${PURPLE} |||${GREEN}U${PURPLE} |||${GREEN}P${PURPLE} ||
||4E|||58|||___20___|||42|||41|||43|||4B|||55|||50||
|/__\|/__\|/________\|/__\|/__\|/__\|/__\|/__\|/__\|${NC}\n"


while [[ $# == 0 ]];do
    echo -e "\nPlease provide an argument:"
    echo -e $HELP
    exit
done

while getopts "brh" opt; do
    case $opt in
	b)
	    # Backup

	    # Turn maintenance mode ON
	    sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --on

	    # Syncronize with backup server, preserving labels and setting a dierctory name based on the current week
	    sudo $RSYNC_COMMAND $NEXTCLOUD_DIR/ backup:$BACKUP_DIR/nextcloud_`date +%Y-%m-%W`/

	    # Dump the database Under a temporary location
	    sudo mysqldump --single-transaction -u root -proot nextcloud > /root/sqlbck/nextcloud-sqlbkp_`date +%Y-%m-%W`.bak

	    # Syncronize the dump with the backup server
	    sudo $RSYNC_COMMAND /root/sqlbck/ backup:$BACKUP_DIR/nextcloud_`date +%Y-%m-%W`/

	    # Delete the local dump
	    rm /root/sqlbck/*

	    # Turn maintenance mode OF
	    sudo -u www-data php $NEXTCLOUD_DIR/occ maintenance:mode --off

	    exit
	    ;;

	r)
	    # Restore

	    # ===================================================================================================
	    # WARNING: delete every data under the /nextcloud directory, be sure to make a backup before using it
	    # ===================================================================================================

	    # Prompt user, and read command line argument
	    read -p "WARNING: this action will first delete any data under the /nextcloud directory, are you sure you want to continue ?" answer

	    # Add backup presence verification

	    while true
	    do
		case $answer in
		    [yY]* )

			rm -r $NEXTCLOUD_DIR

			# Drop previous database
			mysql -u root -proot -e "DROP DATABASE nextcloud"

			# get last backup
			LAST_DIR=$(ssh backup "ls -t $BACKUP_DIR | head -n 1")

			# Restore last backup
			$RSYNC_COMMAND backup:$BACKUP_DIR/$LAST_DIR /var/www/html/

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

		    [nN]* )
			exit;;

		    * )
			echo "Y/N"; break ;;
		esac
	    done

	    h)
	      echo -e $HELP >&2
	      exit;;

	      \?)
		  echo -e $HELP >&2
		  ;;
	      esac
done
