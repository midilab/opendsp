#!/bin/bash
# host dependencies:
# sudo pacman -S multipath-tools parted sshpass zip dosfstools binfmt-support qemu-user-static arch-install-scripts
# Register the qemu-arm-static as an ARM interpreter in the kernel (using binfmt_misc kernel module)
# as root:
#sudo update-binfmts --enable arm
#sudo systemctl enable binfmt-support.service # to load on boot up
# or
# echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > /proc/sys/fs/binfmt_misc/register

boot_size=128
#root_size=3500
root_size=7500
home_size=256
retVal=-1

prepare() {

	image_name=$1

	image_size=$(($boot_size+$root_size+$home_size+64))

	dd if=/dev/zero of=$image_name  bs=1M  count=$image_size
		
	# partitioning
	fdisk $image_name <<EOF
o
n



+$(($boot_size))M
t
c
n



+$(($root_size))M
p
n
p


+$(($home_size))M
p
t
3
b
w
EOF

	# prepare img 

	# losetup
	#kpartx /dev/loop1 -a -v $image_name
	#kpartx -avs
	kpartx -a -v $image_name
	#losetup /dev/loop0 $image_name
	partprobe /dev/loop0
	bootpart=/dev/mapper/loop0p1
	rootpart=/dev/mapper/loop0p2
	homepart=/dev/mapper/loop0p3

	# local sdcard
	#bootpart=/dev/sdb1
	#rootpart=/dev/sdb2
	#homepart=/dev/sdb3

	# setup boot partition
	mkdosfs -n BOOT $bootpart
	# setup root partition
	mkfs.ext4 -L ROOT $rootpart
	# setup user land partition
	mkfs.fat -n OPENDSP $homepart
	sync

	fdisk -l $image_name

	# mount root
	mkdir -v opendsp
	mount -v -t ext4 -o sync $rootpart opendsp
	sync
	# mount boot
	mkdir -v opendsp/boot
	mount -v -t vfat -o sync $bootpart opendsp/boot
	# mount user land
	mkdir -v opendsp/home
	mkdir -v opendsp/home/opendsp
	mkdir -v opendsp/home/opendsp/data
	mount -v -t vfat -o sync $homepart opendsp/home/opendsp/data
}


install() {
		
	# install platform into img
	wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
	bsdtar -xvpf ArchLinuxARM-rpi-2-latest.tar.gz -C opendsp || true
	#tar -xzvf ArchLinuxARM-rpi-2-latest.tar.gz -C opendsp 
	sync

	# cross compile or install packages...
	# prepare for chroot using qemu
	echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > /proc/sys/fs/binfmt_misc/register || true
	cp /usr/bin/qemu-arm-static opendsp/usr/bin/

	mount -t proc /proc opendsp/proc
	mount -o bind /dev opendsp/dev
	mount -o bind /dev/pts opendsp/dev/pts
	mount -o bind /sys opendsp/sys

	# copy packages or modify pacman.conf for our new repository
	#arch-chroot opendsp pacman-key --init
	#arch-chroot opendsp pacman-key --populate archlinuxarm

	retVal=-1
	while [ $retVal -ne 0 ]; do
		chroot opendsp pacman-key --init
		retVal=$?    
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		chroot opendsp pacman-key --populate archlinuxarm  
		retVal=$?  
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		#chroot opendsp pacman -Syyu
		chroot opendsp pacman -Sy
		retVal=$?
	done

	# install dev tool for opendsp packages collection compile
	#chroot opendsp pacman -S base-devel cmake
	#...

	# copy opendsp packaes collection to install partition and install then
	#...

	# resize script for first boot time
	cat <<EOF > opendsp/boot/resize_data_partition.sh
#!/bin/bash -v

set -e

#mount -vo remount,rw /
#mount -vo remount,rw /boot
umount -v /home/opendsp/data || true

parted /dev/mmcblk0 <<EOF
resizepart
3
y
-1M
q
EOF

}	

tunning() {
	# raspberry pi2/pi3 shit
	echo "dtparam=audio=on" >> opendsp/boot/config.txt
	echo "disable_audio_dither=1" >> opendsp/boot/config.txt
	echo "enable_uart=1" >> opendsp/boot/config.txt
	echo "dtoverlay=pi3-miniuart-bt" >> opendsp/boot/config.txt
	echo "dtoverlay=midi-uart0" >> opendsp/boot/config.txt

	echo "hdmi_force_hotplug=1" >> opendsp/boot/config.txt
	#echo "hdmi_drive=2" >> opendsp/boot/config.txt
	#echo "hdmi_group=1" >> opendsp/boot/config.txt
	#echo "hdmi_mode=1" >> opendsp/boot/config.txt

	#echo "cma=128M" >> opendsp/boot/config.txt # broken on newer kernels... dont use it!
	echo "gpu_mem=256" >> opendsp/boot/config.txt
	echo "avoid_warnings=2" >> opendsp/boot/config.txt
	echo "dtoverlay=vc4-kms-v3d" >> opendsp/boot/config.txt

	# take uart usage off
	sed -i 's/ console=ttyAMA0,115200//' opendsp/boot/cmdline.txt
	sed -i 's/ kgdboc=ttyAMA0,115200//' opendsp/boot/cmdline.txt
}	

install_packages() {

	# get opendsp packages and install
	# check if we have binary, if not: get source and compile
	mkdir opendsp/root/opendsp
	cp ../packages/armv7/* opendsp/root/opendsp/

	declare -a package=("mididings-git" "mod-ttymidi" "opendspd" "mod-host-git" "distrho-lv2-git" "midifilter.lv2-git" "fabla-git" "drmr-falktx-git" "swh-lv2-git" "zam-plugins-git" "dpf-plugins-git" "openav-luppp-git" "mixxx" "linux-raspberrypi-rt-opendsp" "linux-raspberrypi-rt-opendsp-headers")
	for i in "${package[@]}"
	do
		retVal=-1
		while [ $retVal -ne 0 ]; do
			chroot opendsp pacman --noconfirm -U "/root/opendsp/${i}.pkg.tar.xz"
			retVal=$?
		done
	done
	
	rm -rf opendsp/root/opendsp/

}

finish() {

	image_name = $1

	#
	chroot opendsp killall gpg-agent || true
	chroot opendsp killall pacman || true

	# after all remove qemu
	rm opendsp/usr/bin/qemu-arm-static

	sync

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp/sys
		retVal=$?
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp/proc
		retVal=$?
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp/dev/pts
		retVal=$?
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp/dev
		retVal=$?
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp/boot
		retVal=$?
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp/home/opendsp/data
		retVal=$?
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount opendsp
		retVal=$?
	done

	rm -rf opendsp
	sync

	# release the image
	kpartx -d -v $image_name
	sync	
	
}
