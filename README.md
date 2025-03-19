# Docker Rsync

## Overview

Initially, I was looking for a ready-made solution but couldn't find one that met my needs, especially with support for ARM and a simple setup. So, I decided to create my own Docker image and share it for others who are also looking for an easy-to-use solution.

By specifying the folder with the SSH key for remote connection, the sync schedule, the remote folder path, along with the host and user details, your files will be copied to the folder on the host where the container is running.

This Docker image provides a lightweight, automated solution for synchronizing remote files using `rsync` over SSH. It is designed for scheduled sync operations using `cron`, ensuring that remote directories stay up to date without manual intervention.

## Features

- Automated file synchronization using `rsync`.
- Secure SSH authentication via private keys.
- Customizable cron scheduling for periodic syncs.
- `PUID` (User ID) and `PGID` (Group ID) set the file ownership for synchronized files. They ensure the files are written with the correct user and group permissions on the host system.
- Lightweight Alpine-based image for minimal resource usage.

## Installation

### Running the Container

```sh
docker run -d \
  --name rsync \
  -v /path/to/local_folder:/data \
  -v /path/to/ssh_keys:/mnt/ssh_keys:ro \
  -e REMOTE_USER=user \
  -e REMOTE_HOST=host.com \
  -e REMOTE_PATH=/remote/directory \
  -e SSH_KEY_FILE=id_rsa \
  -e CRON_SCHEDULE="0 * * * *" \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  --restart unless-stopped \
  insrch/rsync
```

## Environment Variables

| Variable        | Description                                                       | Default  |
| --------------- | ----------------------------------------------------------------- | -------- |
| `REMOTE_USER`   | Username for the remote server                                    | Required |
| `REMOTE_HOST`   | Remote server address                                             | Required |
| `REMOTE_PATH`   | Directory on the remote server to sync from                       | Required |
| `SSH_KEY_FILE`  | SSH private key filename that sould be used for remote connection | `id_rsa` |
| `CRON_SCHEDULE` | Cron expression defining sync schedule                            | Required |
| `PUID`          | User ID for file ownership during sync                            | `1000`   |
| `PGID`          | Group ID for file ownership during sync                           | `1000`   |
| `TZ`            | Timezone for the container (e.g., `UTC`, `Europe/London`)         | `UTC`    |

## Usage Examples

### Basic Usage

```sh
docker run -d \
  -v ~/Downloads:/data:/data \
  -v ~/.ssh:/mnt/ssh_keys:ro \
  -e REMOTE_USER=ubuntu \
  -e REMOTE_HOST=192.168.69.12 \
  -e REMOTE_PATH=/home/ubuntu/downloads \
  -e SSH_KEY_FILE=id_rsa \
  -e CRON_SCHEDULE="0 2 * * *" \
  insrch/rsync
```

This configuration syncs files from the remote directory every day at 2 AM.

### Using Docker Compose

```yaml
services:
  rsync-sync:
    image: your-image-name
    container_name: rsync
    restart: unless-stopped
    volumes:
      - /local/data:/data
      - /path/to/ssh_keys:/mnt/ssh_keys:ro
    environment:
      - REMOTE_USER=user
      - REMOTE_HOST=example.com
      - REMOTE_PATH=/remote/directory
      - SSH_KEY_FILE=id_rsa
      - CRON_SCHEDULE=0 3 * * *
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
```

This example sets up a sync at 3 AM daily using Docker Compose.

## Troubleshooting

### User / Group Identifiers

When using volumes (`-v` flags), permissions issues can occur between the host OS and the container. To avoid this, you can specify the user `PUID` and group `PGID`.

Make sure that any volume directories on the host are owned by the same user and group you specify. This will resolve any permission issues seamlessly.

For example, if `PUID=1000` and `PGID=1000`, you can find your own identifiers by running the following command:

```sh
id your_user
```

Example output:

```sh
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

### SSH Key Not Found

Ensure the SSH key is correctly mounted and the file exists:

```sh
ls -l /path/to/ssh_keys/
```

### Incorrect Permissions

If syncing fails due to permission errors, adjust ownership:

```sh
chown 1000:1000 /local/data -R
```

### Checking Logs

Use the following command to inspect the logs:

```sh
docker logs -f container_id
```

## Contributing

If you would like to contribute, feel free to submit a pull request or open an issue on GitHub.
