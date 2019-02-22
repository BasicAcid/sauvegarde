#! /bin/bash

BCK_HOST="backup"

# Get oldest backup
OLDEST_DIR=$(ssh backup "ls -td */ /root/ | tail -n 1")

# Execute rm by ssh
ssh "rm -r $BCK_HOST:/root/$OLDEST_DIR"
