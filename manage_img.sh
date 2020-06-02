#!/bin/bash 
# dependency: psmisc wget bsdtar 
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
	"create") 
		device=${2##*/}
		image_name=opendsp_${device}-$(date "+%Y-%m-%d").img
		prepare_img $image_name
		install_img
		tunning_img
		exit 0 ;;
	"install") 
		install_img
		exit 0 ;;
	"tune") 
		tunning_img
		exit 0 ;;
	"burn") 
		#zip $1.zip $1
		#dd bs=1M if=$image_name of=$media_device status=progress
		exit 0 ;;
	"mount") 
		mount_img $target
		exit 0 ;;
	"umount") 
		umount_img $target
		exit 0 ;;
esac

echo "please chose mount or umount for an action"
