#!/bin/bash 
# example to manage a OpenDSP image for armv7 version of raspberry pi3/pi2
# ./manage_img.sh mount platform/armv7/raspberry_pi opendsp-...img
# ./manage_img.sh umount platform/armv7/raspberry_pi /dev/loop0

set -e

action=$1
target=$3

#
# Platform create script
#
script=${2}
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