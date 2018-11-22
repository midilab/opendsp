#!/bin/bash 
# example to build an OpenDSP OS for armv7 version of raspberry pi3/pi2
# ./build_os armv7/raspberry_pi

set -e

# globals
platform=${1%%/*}
device=${1##*/}
image_manage=$1
action=$2

image_name=opendsp_${platform}_${device}-$(date "+%Y-%m-%d").img
hostname=opendsp

#
# Opendsp create generic functions
opendsp_install() {
	
	echo $1 > opendsp/etc/hostname
	echo "127.0.1.1 $hostname" >> opendsp/etc/hosts

	cat <<EOF > opendsp/etc/motd

OpenDSP
######################
* MIDI
* OSC
* Keyboard
* Joystick
* Mouse
######################

EOF

}

opendsp_tunning() {

	#
	# post install opendsp realtime setup
	#
	# enable rtirq
	chroot opendsp systemctl enable rtirq	
	# set cpu for performance mode
	sed -i '/governor/d' opendsp/etc/default/cpupower
	echo "governor='performance'" >> opendsp/etc/default/cpupower
	chroot opendsp systemctl enable cpupower
	# get a better swappiness for realtime environment
	echo "vm.swappiness=10" >> opendsp/etc/sysctl.conf

	# set realtime environment for DSPing
	#/etc/pam.d/systemd-user
	#account required pam_unix.so
	#session  required pam_limits.so
	#session optional pam_systemd.so
	# 
	echo "@audio 	- rtprio 	99" >> opendsp/etc/security/limits.conf
	echo "@audio 	- memlock 	unlimited" >> opendsp/etc/security/limits.conf
	# enabling threadirqs
	sed -i 's/ rw/ ro threadirqs/' opendsp/boot/cmdline.txt	
	# disable some services
	chroot opendsp systemctl disable systemd-random-seed || true
}

compress() {
	zip $1.zip $1
}

mount() {
 
	kpartx -a -v $1
	#partprobe /dev/loop0
	bootpart=/dev/mapper/loop0p1
	rootpart=/dev/mapper/loop0p2
	homepart=/dev/mapper/loop0p3

	# mount root
	mkdir -v opendsp
	mount -v -t ext4 -o sync $rootpart opendsp
	
	# mount boot
	mount -v -t vfat -o sync $bootpart opendsp/boot
	
	# mount user land
	mount -v -t ext4 -o sync $homepart opendsp/home/opendsp/data
		
}

umount() {
	
	sync

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount --recursive --lazy opendsp/ || true 
		retVal=$?
	done

	rm -rf opendsp

	# release the image
	kpartx -d -v $1	
	
}

# no platform script needed here
case $action in
	"mount") 
		mount $image_manage
		exit 0 ;;
	"umount") 
		umount $image_manage
		exit 0 ;;
esac

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

# run only a action?
case $action in
	"prepare") 
		prepare $image_name
		exit 0 ;;
	"install") 
		install
		exit 0 ;;
	"tunning") 
		tunning
		exit 0 ;;
	"opendsp_install") 
		opendsp_install $hostname
		exit 0 ;;	
	"install_packages") 
		install_packages
		exit 0 ;;		
	"opendsp_tunning") 
		opendsp_tunning
		exit 0 ;;	
	"finish") 
		finish $image_name
		exit 0 ;;	
esac
 
# partitioning and prepare root, boot(in case) and userland
# partitions path ready for use after prepare function: opendsp, opendsp/boot, opendsp/home/opendsp/data
prepare $image_name

# install base archlinux on disk image 
install

# platform specific tunnings
tunning

# generic and non platform dependent opendsp install 
opendsp_install $hostname

# opendsp meta install
install_packages

# generic and non platform dependent opendsp tunning parameters for reatime kernel and ecosystem setup
opendsp_tunning

# finishing image
finish $image_name

# compress this bastard
compress $image_name

# write to media device?
#media_device=/dev/sdc
#dd bs=1M if=$image_name of=$media_device status=progress

#FINISHED

exit 0
