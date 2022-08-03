#!/bin/bash

MOUNT_EXFAT="/bin/mount.exfat"

if [ "$2" == "exfat" ]; then
	if [ -x "$MOUNT_EXFAT" ]; then
		"$MOUNT_EXFAT" "$@"
	else
		/bin/mount.bin "$@"
	fi
else
	/bin/mount.bin "$@"
fi

exit 0 
