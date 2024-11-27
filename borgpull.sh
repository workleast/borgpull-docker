#!/bin/sh
MOUNT_DIR=/tmp/sshfs
CMD=
case "$1" in
   "create") CMD=/borgpull/borgpull-create.sh
      ;;
   "init") borg init --encryption=none /backups
      exit 0
      ;;
   "list") borg list /backups
      exit 0
      ;;
   "delete")
      if [ $# -lt 2 ]; then
        echo 1>&2 "$0: please provide an archive name"
        exit 2
      fi
      borg delete /backups::$2
      borg compact /backups
      exit 0
      ;;
   "restore")
      if [ $# -lt 2 ]; then
        echo 1>&2 "$0: please provide an archive name"
        exit 2
      fi
      CMD=/borgpull/borgpull-restore.sh
      ;;
   *) echo "invalid usage" 
      exit 1 
      ;;
esac

# mount server's root directory
mkdir $MOUNT_DIR
sshfs -o allow_other -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ${BACKUP_ADDR}:/ $MOUNT_DIR || echo "Connection to server failed, please check your settings" exit 1
echo "Connected to server, please wait..."

# mount borg's repo
mkdir $MOUNT_DIR/borgrepo
mount --bind /backups $MOUNT_DIR/borgrepo
# mount important system directories
cd $MOUNT_DIR
for i in dev proc sys; do mount --bind /$i $i; done
# copy borg to server
cp /usr/bin/borg $MOUNT_DIR/usr/local/bin/borg
# copy borgpull files to server
mkdir $MOUNT_DIR/borgpull
echo "#!/bin/sh" > $MOUNT_DIR/borgpull/borgpull-create.sh
echo "borg create --stats --progress --exclude borgrepo --files-cache ctime,size /borgrepo::$ARCHIVE_NAME $TARGET_DIR" >> $MOUNT_DIR/borgpull/borgpull-create.sh
chmod +x $MOUNT_DIR/borgpull/borgpull-create.sh
echo "#!/bin/sh" > $MOUNT_DIR/borgpull/borgpull-restore.sh
echo "borg extract --list /borgrepo::$2 $TARGET_DIR" >> $MOUNT_DIR/borgpull/borgpull-restore.sh
chmod +x $MOUNT_DIR/borgpull/borgpull-restore.sh

# run borgpull commands
chroot $MOUNT_DIR $CMD

# cleanup and unmount
rm $MOUNT_DIR/usr/local/bin/borg
cd $MOUNT_DIR
for i in dev proc sys borgrepo; do umount ./$i; done
rmdir borgrepo
rm -r borgpull
cd ~
umount $MOUNT_DIR
rmdir $MOUNT_DIR
