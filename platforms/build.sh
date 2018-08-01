#!/bin/bash 
#
# host dependencies:
# sudo pacman -S multipath-tools parted sshpass zip dosfstools binfmt-support qemu-user-static arch-install-scripts
# Register the qemu-arm-static as an ARM interpreter in the kernel (using binfmt_misc kernel module)
# as root:
#sudo update-binfmts --enable arm
#sudo systemctl enable binfmt-support.service # to load on boot up
# or
# echo ':arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\xff\xff\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:' > /proc/sys/fs/binfmt_misc/register

set -e

platform=$1

image_name=opendsp_${platform}_$(date "+%Y-%m-%d").img
#image_name=/dev/sdb
hostname=opendsp

# above we have platform specific script
# rpi3 script pre_build(image_name)
boot_size=128
root_size=4000
home_size=256
image_size=$(($boot_size+$root_size+$home_size+64))

dd if=/dev/zero of=$image_name  bs=1M  count=$image_size

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
mkdir -v opendsp/home/opendsp/userland
mount -v -t vfat -o sync $homepart opendsp/home/opendsp/userland

# check platform script 
# install platform into img
##wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
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

chroot opendsp pacman-key --init
chroot opendsp pacman-key --populate archlinuxarm

#chroot opendsp pacman -Syyu
chroot opendsp pacman -Sy

# install dev tool for opendsp packages collection compile
#chroot opendsp pacman -S base-devel cmake
#...

# copy opendsp packaes collection to install partition and install then
#...

: '
cat <<EOF > /etc/fstab
/dev/mmcblk0p1  /boot           vfat    ro,auto,exec            0       2
/dev/mmcblk0p2  /               auto    defaults,noatime,ro     0       1
EOF
# /dev/mmcblk0p1  /boot           vfat    ro,auto,exec            0       2
# /dev/mmcblk0p2  /               auto    defaults,noatime,ro     0       1
# /dev/mmcblk0p3  /samples        auto    ro,auto,exec            0       0
EOF
'

# make the entire system read only
: '
#!/bin/sh

# shhd access because it wont work sudo with ro
vi /etc/ssh/sshd_config
#Add "PermitRootLogin yes"

# boot args
root=/dev/mmcblk0p2 ro rootwait console=tty1 selinux=0 plymouth.enable=0 smsc95
xx.turbo_mode=N dwc_otg.lpm_enable=0 elevator=noop

# Readonly filesystems
#/dev/mmcblk0p1 /boot vfat ro,noatime 0 2
#/dev/mmcblk0p2 / ext4 defaults,noatime 0 1
/dev/mmcblk0p1	 /boot	 vfat	 defaults,ro,errors=remount-ro        0       0

# RAM filesystem for runtime shit
tmpfs           /var/tmp        tmpfs   defaults,noatime,mode=0755      0       0
tmpfs           /var/log        tmpfs   defaults,noatime,mode=0755      0       0

# disable some services
systemctl disable systemd-random-seed
'

# audio stuff alsa
#vi /boot/config.txt
#dtparam=audio=on

# free the serial UART for us to use with uMODULAR
#sudo vi /boot/cmdline.txt
#>take off all ttyAMA0 references
# we dont have this guy on archlinux and systemd
#sudo vi /etc/inittab
#>take off all ttyAMA0 references

# opendsp install
# basic setup
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

cat <<EOF > opendsp/boot/resize_userland_partition.sh
#!/bin/bash -v

set -e

mount -vo remount,rw /
mount -vo remount,rw /boot
umount -v /home/opendsp/userland || true

parted /dev/mmcblk0 <<EOF
resizepart
3
y
-1M
q
EOF

: '
# run again in case the `y` above fails
parted /dev/mmcblk0 <<EOF
resizepart
3
-1M
q
EOF
'

# add opendsp repository
#sed -i opendsp/etc/apt/sources.list -e "s/main/main contrib non-free firmware/"
#echo "deb http://archive.raspberrypi.org/debian/ jessie main" >> opendsp/etc/apt/sources.list
#...

# get opendsp packages and install
# check if we have binary, if not: get source and compile

# useradd --create-home --groups wheel --shell /bin/bash michael
# passwd michael

# [chroot]# exit

# after all remove qemu
rm opendsp/usr/bin/qemu-arm-static

sync
umount opendsp/{sys,proc,dev/pts,dev,boot,home/opendsp/userland}
umount opendsp
rm -rf opendsp
sync

# release the image
kpartx -d -v $image_name
sync

# compress this bastard
zip $image_name.zip $image_name

# write to sdcard
#
dd bs=1M if=$image_name of=/dev/sdc status=progress

#FINISHED

exit 0
