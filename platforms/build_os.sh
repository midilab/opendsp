#!/bin/bash 
# example to build an OpenDSP OS for armv7 version of raspberry pi3/pi2
# ./build armv7 raspberry_pi

set -e

# globals
platform=$1
device=$2
image_name=opendsp_${platform}_${device}-$(date "+%Y-%m-%d").img
hostname=opendsp

#
# Platform create script
#
script=${platform}/${device}.sh
if [ ! -f "$script" ]
then
	echo "$0: platform script '${script}' not found."
	exit -1
fi

# import platform specific create script
source ${script}

# partitioning and prepare root, boot(in case) and userland
# partitions path ready for use after prepare function: opendsp, opendsp/boot, opendsp/home/opendsp/data
prepare $image_name

# install base archlinux on disk image 
install

# platform specific tunnings
tunning

#
# OpenDSP default install
#
echo $hostname > opendsp/etc/hostname
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

# opendsp meta install
#...
install_packages

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

# finishing image
finish $image_name

# compress this bastard
zip $image_name.zip $image_name

# write to media device?
#media_device=/dev/sdc
#dd bs=1M if=$image_name of=$media_device status=progress

#FINISHED

exit 0
