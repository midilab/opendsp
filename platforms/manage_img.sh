#!/bin/bash 
# example to build an OpenDSP OS for armv7 version of raspberry pi3/pi2
# ./manage_img.sh mount armv7/raspberry_pi opendsp-...img
# ./manage_img.sh umount armv7/raspberry_pi /dev/loop0

set -e

# globals
platform=${2%%/*}
device=${2##*/}

action=$1
target=$3

#
# Platform create script
#
script=${platform}/${device}
if [ ! -f "$script" ]
then
	echo "$0: platform script '${script}' not found."
	exit -1
fi

# import platform specific create script
source ${script}
 
case $action in
	"mount") 
		mount_img $target
		exit 0 ;;
	"umount") 
		umount_img $target
		exit 0 ;;
esac

echo "please chose mount or umount for an action"
