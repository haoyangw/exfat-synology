#!/bin/bash

# Ensure that script is run as root

if [ "$EUID" -ne 0 ]; then
	echo "ERROR: Please run $0 as root. Exiting"
    exit 1
fi

# Check that required files are present

INSMOD=$(which insmod)
RMMOD=$(which rmmod)
LSMOD=$(which lsmod)
RM=$(which rm)
CP=$(which cp)
MV=$(which mv)
CHMOD=$(which chmod)

if [ -z "$INSMOD" ]; then
	echo "ERROR: insmod binary missing, cannot continue. Exiting"
	exit 1
fi

if [ -z "$RMMOD" ]; then
	echo "ERROR: rmmod binary missing, cannot continue. Exiting"
	exit 1
fi

if [ -z "$RM" ]; then
	echo "ERROR: rm binary missing, cannot continue. Exiting"
	exit 1
fi

if [ -z "$CP" ]; then
	echo "ERROR: cp binary missing, cannot continue. Exiting"
	exit 1
fi

if [ -z "$MV" ]; then
	echo "ERROR: mv binary missing, cannot continue. Exiting"
	exit 1
fi

if [ -z "$CHMOD" ]; then
	echo "ERROR: chmod binary missing, cannot continue. Exiting"
	exit 1
fi

# Uninstallation
MODULES_PATH=/lib/modules
BIN_PATH=$(dirname "$(which mount)")
EXFAT_BAK=exfat-stock.ko.bak

LOADED_EXFAT=$("$LSMOD" | grep exfat)

if [ -n "$LOADED_EXFAT" ]; then
	echo "Unloading exFAT kernel module before uninstalling"
	"$RMMOD" "${MODULES_PATH}/exfat.ko"
fi

if [ -f "${MODULES_PATH}/$EXFAT_BAK" ]; then
	if [ -f "${MODULES_PATH}/exfat.ko" ]; then
		echo "Removing our own exFAT kernel module from your system"
		"$RM" "${MODULES_PATH}/exfat.ko"
	fi
	"$MV" "${MODULES_PATH}/$EXFAT_BAK" "${MODULES_PATH}/exfat.ko"
fi

if [ -n "$LOADED_EXFAT" ]; then
	"$INSMOD" "${MODULES_PATH}/exfat.ko"
fi

if [ -f "${BIN_PATH}/mount.bin" ]; then
	if [ -f "${BIN_PATH}/mount" ]; then
		echo "Removing our mount wrapper script"
		"$RM" "${BIN_PATH}/mount"
	fi
	"$MV" "${BIN_PATH}/mount.bin" "${BIN_PATH}/mount"
	"$CHMOD" 0755 "${BIN_PATH}/mount"
fi

if [ -f "${BIN_PATH}/mount.exfat" ]; then
	"$RM" "${BIN_PATH}/mount.exfat"
	if [ -f "${BIN_PATH}/mount-stock.exfat.bak" ]; then
		"$MV" "${BIN_PATH}/mount-stock.exfat.bak" "${BIN_PATH}/mount.exfat"
		"$CHMOD" 0755 "${BIN_PATH}/mount.exfat"
	fi
fi

echo "Uninstallation complete!"
exit 0

