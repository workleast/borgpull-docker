FROM alpine:20240807
LABEL maintainer="workleast.com"

ENV BACKUP_ADDR=0.0.0.0
ENV TZ=Asia/Ho_Chi_Minh
ENV ARCHIVE_NAME=archive-{now:%Y-%m-%dT%H:%M:%S}
ENV TARGET_DIR=/

#Install Borg & SSH
RUN apk add --no-cache \
    tzdata \
    openssh-client=9.9_p1-r1 \
    sshfs=3.7.3-r1 \
    fuse=2.9.9-r6 \
    borgbackup=1.4.0-r0 \
    supervisor=4.2.5-r5
RUN mkdir /backups && \
    mkdir /root/.ssh
RUN sed -i \
        -e 's/^#user_allow_other$/user_allow_other/g' \
        /etc/fuse.conf

COPY supervisord.conf /etc/supervisord.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY borgpull.sh /usr/local/bin/borgpull

CMD ["/usr/bin/supervisord"]
