FROM alpine:latest

RUN apk add --no-cache openssh-client rsync util-linux bash tzdata

COPY entrypoint.sh /entrypoint.sh
COPY sync_script.sh /sync_script.sh

RUN chmod +x /entrypoint.sh /sync_script.sh

VOLUME /data

CMD ["/entrypoint.sh"]