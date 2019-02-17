#! /bin/bash

# Get oldest backup
OLDEST_DIR=$(ssh backup "ls -t /root/backups/nextcloud/ | tail -n 1")

# Execute rm by ssh
ssh "rm -r backup:/root/backups/nextcloud/$OLDEST_DIR"
