#!/usr/bin/env bash

# Remount bind mounts
mounts=
for i in $(mount | grep bind | sed 's#^.* on \([^ ]\+\).*$#\1#g')
do
    mounts="${mounts} ${i}"
done
sudo -- sh -c "umount ${mounts} > /dev/null 2>&1; mount -a"
