#!/bin/bash

source /etc/environment

if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_PATH" ] ; then
    echo "Error: One or more required environment variables are missing" >&2
    exit 1
fi

echo "$(date '+%Y-%m-%d %H:%M:%S') Starting sync..."
(
  flock -n 200 || { echo "Another instance is running, exiting."; exit 1; }
  rsync -rvz --checksum \
    --exclude='*.Trash*' --exclude='lost+found' --exclude='System Volume Information' \
    --bwlimit=5M \
    --chown=${PUID}:${PGID} \
    -e "ssh -i /.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=ERROR" \
    "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" \
    /data

  echo "$(date '+%Y-%m-%d %H:%M:%S') Sync completed successfully."

) 200>/var/lock/sync_script.lock
