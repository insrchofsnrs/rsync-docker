#!/bin/bash

if [ -z "$CRON_SCHEDULE" ]; then
  echo "Error: CRON_SCHEDULE variable is not set" >&2
  exit 1
fi

export SSH_KEY_FILE=${SSH_KEY_FILE:-id_rsa}
export PUID=${PUID:-1000}
export PGID=${PGID:-1000}

if [ -z "$REMOTE_USER" ] || [ -z "$REMOTE_HOST" ] || [ -z "$REMOTE_PATH" ]; then
  echo "Error: One or more required environment variables (REMOTE_USER, REMOTE_HOST, REMOTE_PATH) are missing" >&2
  exit 1
fi

if [ ! -f "/mnt/ssh_keys/$SSH_KEY_FILE" ]; then
  echo "Error: SSH private key not found at /mnt/ssh_keys/$SSH_KEY_FILE" >&2
  exit 1
fi

mkdir -p /.ssh
cp "/mnt/ssh_keys/$SSH_KEY_FILE" "/.ssh/id_rsa"
chmod 700 /.ssh
chmod 600 /.ssh/id_rsa

echo "export REMOTE_USER=\"$REMOTE_USER\"" > /etc/environment
echo "export REMOTE_HOST=\"$REMOTE_HOST\"" >> /etc/environment
echo "export REMOTE_PATH=\"$REMOTE_PATH\"" >> /etc/environment
echo "export PUID=\"$PUID\"" >> /etc/environment
echo "export PGID=\"$PGID\"" >> /etc/environment

echo "$CRON_SCHEDULE . /etc/environment; /bin/bash /sync_script.sh >> /proc/1/fd/1 2>&1" > /etc/crontabs/root

chmod 0644 /etc/crontabs/root

echo "rsync cron job scheduled"
exec crond -f
