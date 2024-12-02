# borgpull-docker
A docker container that run Borg backup in pull mode

Xem hướng dẫn sử dụng bằng Tiếng Việt tại đây: https://workleast.com/sao-luu-du-lieu-voi-borg-pull-docker/

Borg Backup Pull Mode Docker Container enabled ability to backup your data by pulling them from your server without the need of setting up a dedicated backup server.

Usage
===
```
services:
  borgpull:
    build:
      context: .
    restart: always
    image: workleast/borgpull
    container_name: borgpull
    volumes:
      - path/to/repository:/backups # replace with your actual path to repository directory here
      - ./config/ssh/id_rsa:/root/.ssh/id_rsa # replace with your SSH private key file
      - ./config/crontab.txt:/etc/crontabs/root # edit crontab.txt file to schedule automatic backups
    environment:
      TZ: "Asia/Ho_Chi_Minh"
      BACKUP_ADDR: "user@server_ip" # replace with your actual backup server's address here
      ARCHIVE_NAME: "archive-{now:%Y-%m-%dT%H:%M:%S}"
      TARGET_DIR: "/" # replace with your target directory (to be backed up) in the backup server
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse
    security_opt:
      - apparmor:unconfined
```
Initialize Borg's repository (only run once at the first time)
===
```
docker exec -it borgpull borgpull init
```
Create an archive (backup) manually
===
```
docker exec -it borgpull borgpull create
```
List all archives
===
```
docker exec -it borgpull borgpull list
```
Delete an archive
===
```
docker exec -it borgpull borgpull delete ARCHIVE_NAME
```
Restore an archive
===
```
docker exec -it borgpull borgpull restore ARCHIVE_NAME
```
