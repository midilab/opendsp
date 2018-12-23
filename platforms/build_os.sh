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
	echo "127.0.1.1 $1" >> opendsp/etc/hosts
	
	echo "" > opendsp/etc/motd
	cat <<EOF > opendsp/etc/issue


 ██████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗██████╗ 
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║  ██║███████╗██████╔╝
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔═══╝ 
╚██████╔╝██║     ███████╗██║ ╚████║██████╔╝███████║██║     
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝     

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
	# enabling threadirqs and boot read only file system and other system options
	sed -i 's/ rw/ ro threadirqs fsck.repair=yes nohz=off/' opendsp/boot/cmdline.txt	
	# disable some services
	chroot opendsp systemctl disable systemd-random-seed || true
	
	# newer archlinux versions need to generate ssh keys by our own
	chroot opendsp ssh-keygen -P "" -f /etc/ssh/ssh_host_rsa_key
	
	# setup samba share for user data
	# run for the first time to create dir structure
	chroot opendsp systemctl start smb
	chroot opendsp systemctl start nmb	
	chroot opendsp systemctl stop nmb
	chroot opendsp systemctl stop smb	
	chroot opendsp smbpasswd -a opendsp -n
	cat <<EOF > opendsp/etc/samba/smb.conf	
[global]
  workgroup = OpenDSPGroup
  server string = "Use this share to access all your opendsp user data" 
  guest account = opendsp
  passdb backend = tdbsam
  load printers = no
  printing = bsd
  printcap name = /dev/null
  disable spoolss = yes
  show add printer wizard = no
  security = user
  map to guest = Bad User
  create mask = 0644
  directory mask = 0755  

[user]
  comment = OpenDSP user data 
  path = /home/opendsp/data
  writable = yes
  printable = no
  public = yes
EOF

	# enable service at boot time
	chroot opendsp systemctl enable smb
	chroot opendsp systemctl enable nmb	

	# little hack that enable us to start samba on read only file system
	mv opendsp/var/cache/samba opendsp/var/cache/samba.cp
	mkdir opendsp/var/cache/samba
	mv opendsp/var/lib/samba opendsp/var/lib/samba.cp
	mkdir opendsp/var/lib/samba
	chroot opendsp systemctl enable sambafix
	cat <<EOF >> opendsp/etc/fstab
# ram memory runtime filesystems
tmpfs           /var/tmp        tmpfs   defaults,noatime,mode=0755      0       0
tmpfs           /var/log        tmpfs   defaults,noatime,mode=0755      0       0
# samba fix for read only environment
tmpfs           /var/cache/samba tmpfs   defaults,noatime,mode=0755      0       0
tmpfs           /var/lib/samba   tmpfs   defaults,noatime,mode=0755      0       0
EOF
	
	# disable some systems
	chroot opendsp systemctl disable systemd-timesyncd
}

compress() {
	zip $1.zip $1
}

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
 
# partitioning and prepare root, boot(in case) and userland
# partitions path ready for use after prepare function: opendsp, opendsp/boot, opendsp/home/opendsp/data
prepare $image_name

# install base archlinux on disk image 
install

# generic and non platform dependent opendsp install 
opendsp_install $hostname

# opendsp meta install
install_packages

# platform specific tunnings
tunning

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
