#!/bin/bash

# Ensure that script is run as root

if [ "$EUID" -ne 0 ]; then
	echo "ERROR: Please run $0 as root. Exiting"
    exit 1
fi

THIS_DIR=$(pwd)
VERSION=5.14.1

# Check that required files are present

if [ ! -f "./exfat.ko" ]; then
	echo "ERROR: exFAT kernel module missing, cannot continue. Exiting"
	exit 1
fi

if [ ! -f "./mount.sh" ]; then
	echo "ERROR: mount wrapper script missing, cannot continue. Exiting"
	exit 1
fi

if [ ! -f "./mount.static" ]; then
	echo "ERROR: built-from-source mount binary missing, cannot continue. Exiting"
	exit 1
fi

INSMOD=$(which insmod)
RMMOD=$(which rmmod)
LSMOD=$(which lsmod)
RM=$(which rm)
CP=$(which cp)
MV=$(which mv)
CHMOD=$(which chmod)
MOUNT=$(which mount)

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

if [ -z "$MOUNT" ]; then
	echo "ERROR: mount binary missing, cannot continue. Exiting"
	exit 1
fi

# Installation

MODULES_PATH=/lib/modules
BIN_PATH=$(dirname "$(which mount)")

# Check for previous installation of exFAT kernel module
if [ -f "${MODULES_PATH}/exfat-stock.ko.bak" ]; then
	if [ -f "${MODULES_PATH}/exfat.ko" ]; then
		echo "exFAT kernel module from previous installation found. Removing first before we install the current version"
		"$RMMOD" "${MODULES_PATH}/exfat.ko"
		"$RM" "${MODULES_PATH}/exfat.ko"
	fi
else
	if [ -f "${MODULES_PATH}/exfat.ko" ]; then
		EXFAT_LOADED=$("$LSMOD" | grep "exfat")
		if [ -n "$EXFAT_LOADED" ]; then
			"$RMMOD" "${MODULES_PATH}/exfat.ko"
		fi
		echo "Backing up stock exFAT kernel module before replacing it with ours"
		"$CP" -f "${MODULES_PATH}/exfat.ko" ./exfat-stock.ko.bak
		"$MV" "${MODULES_PATH}/exfat.ko" "${MODULES_PATH}/exfat-stock.ko.bak"
	fi
fi

echo "Installing exFAT kernel module from Linux ${VERSION}"
"$CP" ./exfat.ko "${MODULES_PATH}/exfat.ko"

# Check for previous installation of our own mount binary/wrapper script
if [ -f "${BIN_PATH}/mount.bin" ]; then
	if [ -f "${BIN_PATH}/mount" ]; then
		echo "mount wrapper script from previous installation found, removing it before continuing"
		"$RM" "${BIN_PATH}/mount"
	fi
else
	echo "Backing up stock mount binary before installing our mount wrapper script"
	"$CP" -f "${BIN_PATH}/mount" ./mount-stock.bak
	"$MV" "${BIN_PATH}/mount" "${BIN_PATH}/mount.bin"
fi

echo "Installing our mount wrapper script"
"$CP" ./mount.sh "${BIN_PATH}/mount"
"$CHMOD" 0755 "${BIN_PATH}/mount"

if [ -f "${BIN_PATH}/mount.exfat" ]; then
	if [ -f "${BIN_PATH}/mount-stock.exfat.bak" ]; then
		echo "Upstream mount.exfat binary from previous installation found, removing it before continuing"
		"$RM" "${BIN_PATH}/mount.exfat"
	else	
		echo "Backing up stock mount.exfat binary before continuing"
		"$CP" -f "${BIN_PATH}/mount.exfat" ./mount-stock.exfat.bak
		"$MV" "${BIN_PATH}/mount.exfat" "${BIN_PATH}/mount-stock.exfat.bak"
	fi
fi

echo "Installing our upstream mount binary"
"$CP" ./mount.static "${BIN_PATH}/mount.exfat"
"$CHMOD" 0755 "${BIN_PATH}/mount.exfat"

echo "Loading exFAT kernel module"
"$INSMOD" "${MODULES_PATH}/exfat.ko"

echo "Installation complete! If exFAT kernel module is loaded successfully, it should be displayed below"
"$LSMOD" | grep exfat
exit 0

