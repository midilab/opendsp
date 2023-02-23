#!/bin/bash 
# host dependencies:
# on archlinux
# sudo pacman -S multipath-tools parted sshpass zip dosfstools binfmt-support qemu-user-static arch-install-scripts
# most debian based
# sudo apt-get install multipath-tools parted sshpass zip dosfstools binfmt-support qemu-user-static
# Register the qemu-arm-static as an ARM interpreter in the kernel (using binfmt_misc kernel module)
# as root:
#sudo update-binfmts --enable arm
#sudo systemctl enable binfmt-support.service # to load on boot up
# using only docker still needs qemu-user-static-binfmt on host

#set -e

declare action="${1}"
declare arch="${2}"
declare device="${3}"
declare image="${4}"
declare customization="${4}"

declare loop_device=''

# sdcard partition layout
declare sector_start=-1
declare -a partition_type
declare -a partition_size
declare -a partition_label
declare -a partition_mnt
declare filesystem_image=''

# for additional packaging install
declare -a packages

# throws all output to log file, except those on stdout 7
# save a copy of current stdout
#exec 7>&1 
#exec > "${BUILDER_PATH}/build/log.txt"
#exec  > "${BUILDER_PATH}/build/log.txt" 2>&1 
#exec &> "${BUILDER_PATH}/build/log.txt"

print() {
	string="${1}"
	#echo "$string" >&7
	echo "${string}"
}

# no customization defined? archlinuxarm is default
if [ "${customization}" == "" ]; then
	customization="archlinuxarm"
fi
#
# Platform create script
#
script="${BUILDER_PATH}/platforms/${arch}/${device}.build"
if [ ! -f "$script" ]
then
	echo "${0}: platform script '${script}' not found."
	exit -1
fi

# import platform specific create script
source ${script}

bootstrap_img() {
		
	if [ ! -d "${ROOT_MOUNT}/lost+found" ]
	then
		echo "no lost found"
	fi

	# download or use it local?
	if [ ! -f "${filesystem_image}" ]
	then
		# download it!
		wget "${RELEASE_DOWNLOAD_URL}/${filesystem_image}"
	fi
	# install filesystem_image
	bsdtar -xvpf ${filesystem_image} -C ${ROOT_MOUNT}

	# any post install action to be done?
	post_filesystem_install

	retVal=-1
	while [ ${retVal} -ne 0 ]; do
		chroot ${ROOT_MOUNT} pacman-key --init
		retVal=$?    
	done

	retVal=-1
	while [ ${retVal} -ne 0 ]; do
		chroot ${ROOT_MOUNT} pacman-key --populate archlinuxarm
		retVal=$?  
	done

	retVal=-1
	while [ ${retVal} -ne 0 ]; do
		chroot ${ROOT_MOUNT} pacman -Syu --noconfirm
		retVal=$?
	done

	retVal=-1
	while [ ${retVal} -ne 0 ]; do
		chroot ${ROOT_MOUNT} ssh-keygen -A
		retVal=$?  
	done
}	

install_packages() {
	pack_list=("$@")
	retVal=-1
	while [ $retVal -ne 0 ]; do
		chroot ${ROOT_MOUNT} pacman -S "${pack_list[@]}" --noconfirm
		retVal=$?
	done
}

prepare_img() {

	image_name=${1}
	image_size=0

    for size in ${partition_size[@]}; do
		image_size=$((image_size+size))
    done
	image_size=$((image_size+64))
	
	dd if=/dev/zero of=${image_name}  bs=1M  count=${image_size}
		
	# initialize disk
	fdisk "${image_name}" <<EOF
o
w
EOF

	# creating partition table
    for i in ${!partition_type[@]}; do
        # one by one
		size=${partition_size[$i]}		
		fdisk "${image_name}" <<EOF
n



+$(($size))M
w
EOF

		# change type?
		if [ "${partition_type[$i]}" == "fat" ]; then
			fdisk "${image_name}" <<EOF
t
$(($i+1))
c
w
EOF
		fi

    done

	# move first partition sector to sector_start if it is defined
	if [ ${sector_start} -ge 0 ]; then
		fdisk "${image_name}" <<EOF
x
b
1
$(($sector_start))
r
w
EOF
	fi

	# prepare img
	loop_device="$(losetup --show -f -P "${image_name}")"

	# formating partitions
    for i in ${!partition_type[@]}; do
		p=$((i+1))
        # one by one
		if [ ${partition_type[$i]} == "fat" ]; then
			mkfs.fat -n ${partition_label[$i]} "${loop_device}p${p}"
		elif [ ${partition_type[$i]} == "ext4" ]; then
			mkfs.ext4 -L ${partition_label[$i]} "${loop_device}p${p}"
		fi
	done

	# print final partition table for debug
	fdisk -l "${image_name}"
}

mount_img() {
	
	image_name=${1}
	
	if [ -d "${ROOT_MOUNT}/" ]; then
    	echo "file system mounted"
		return
	fi

	if [ "${loop_device}" == "" ]; then
		# mount on loop loop_device
		loop_device="$(losetup --show -f -P "${image_name}")"
	fi

	# mounting first root /
	mkdir -p ${ROOT_MOUNT}/
    for i in ${!partition_mnt[@]}; do
		if [ "${partition_mnt[$i]}" == "/" ]; then
			p=$((i+1))
			mount -v -t ext4 -o sync "${loop_device}p${p}" ${ROOT_MOUNT}${partition_mnt[$i]}
		fi
	done

	# mounting partitions
    for i in ${!partition_mnt[@]}; do
		# already mounted above
		if [ "${partition_mnt[$i]}" == "/" ]; then
			continue
		fi
		p=$((i+1))
        # one by one
		mkdir -p ${ROOT_MOUNT}${partition_mnt[$i]}
		if [ "${partition_type[$i]}" == "fat" ]; then
			mount -v -t vfat -o sync "${loop_device}p${p}" ${ROOT_MOUNT}${partition_mnt[$i]}
		elif [ "${partition_type[$i]}" == "ext4" ]; then
			mount -v -t ext4 -o sync "${loop_device}p${p}" ${ROOT_MOUNT}${partition_mnt[$i]}
		fi
	done

	# good idea to have those mounted as we chroot in
	mkdir -p ${ROOT_MOUNT}/proc
	mkdir -p ${ROOT_MOUNT}/sys
	mkdir -p ${ROOT_MOUNT}/dev/pts
	mkdir -p ${ROOT_MOUNT}/tmp
	mkdir -p ${ROOT_MOUNT}/run
	mkdir -p ${ROOT_MOUNT}/dev/shm
	mkdir -p ${ROOT_MOUNT}/sys/fs/bpf 
	mkdir -p ${ROOT_MOUNT}/dev/mqueue
	mkdir -p ${ROOT_MOUNT}/var/tmp
	# bind then
	mount -o bind /proc ${ROOT_MOUNT}/proc
	mount -o bind /sys ${ROOT_MOUNT}/sys
	mount -o bind /dev ${ROOT_MOUNT}/dev
	mount -o bind /dev/pts ${ROOT_MOUNT}/dev/pts
	mount -o bind /tmp ${ROOT_MOUNT}/tmp
	mount -o bind /run ${ROOT_MOUNT}/run
	mount -o bind /dev/shm ${ROOT_MOUNT}/dev/shm
	mount -o bind /sys/fs/bpf ${ROOT_MOUNT}/sys/fs/bpf 
	mount -o bind /dev/mqueue ${ROOT_MOUNT}/dev/mqueue
	mount -o bind /var/tmp ${ROOT_MOUNT}/var/tmp

	# prepare for chroot using qemu
	mkdir -p ${ROOT_MOUNT}/usr/bin
	cp /usr/bin/qemu-arm-static ${ROOT_MOUNT}/usr/bin/	
	
	# copy temporarly our resolv.conf to get internet connection
	mkdir -p ${ROOT_MOUNT}/run/systemd/resolve/
	cp /etc/resolv.conf ${ROOT_MOUNT}/run/systemd/resolve/
	
}

umount_img() {

	image_name=${1}
	
	if [ ! -d "${ROOT_MOUNT}/" ]; then
    	echo "file system not mounted"
		return
	fi

	# just in case, sometimes they can lock /dev/
	kill -9 `pgrep gpg-agent`
	kill -9 `pgrep pacman`
	 
	# remove any installed packages on /var/cache/pacman/pkg/
	rm ${ROOT_MOUNT}/var/cache/pacman/pkg/*

	# remove our systemd resolv.conf
	rm -rf ${ROOT_MOUNT}/run/systemd/

	# after all remove qemu
	rm ${ROOT_MOUNT}/usr/bin/qemu-arm-static

	# make sure everything is up to date on card before umount it
	sync

	retVal=-1
	while [ ${retVal} -ne 0 ]; do
		umount --recursive ${ROOT_MOUNT}/ 
		retVal=$?
	done

	rm -rf ${ROOT_MOUNT}
	
	# release the image loop device
	if [ "${loop_device}" == "" ]; then
		# release all loopdevices
		#losetup -D
		echo "please check manually your loop device to delete it: sudo losetup -d /dev/loopX"
	else
		losetup -d "${loop_device}"
	fi
}

emulate() {
	image_name=${1}

	mount_img ${image_name} 
	# chroot into image by using qemu-arm-static
	chroot ${ROOT_MOUNT} /bin/bash
	umount_img ${image_name} 
}

# operates everything from build path
cd ${BUILDER_PATH}/build/

case $action in

	"create") 
        if [ "${customization}" != "" ]; then
          # get customization script
		  # this is running after source platform script!
		  source ${BUILDER_PATH}/customizations/${customization}/${customization}.build
        fi
		image=${customization}-${arch}-${device}-$(date "+%Y-%m-%d").img
		print "preparing image..."
		prepare_img $image
		mount_img $image
		print "bootstraping image..."
		bootstrap_img
		# any additional requested packages to install?
		if [ ${#packages[@]} -ne 0 ]; then
			print "installing additional packages"
			install_packages "${packages[@]}"
		fi
		print "tunning image for ${device}:${arch}"
		tunning_img
		if [ "${customization}" != "" ]; then
			print "starting ${customization} customization..."
			customize
		fi
		print "sdcard image created at: builder/build/${image}"
		exit 0 ;;

	"customize") 
		print "starting ${customization} customization..."
		mount_img $image
		source ${BUILDER_PATH}/customizations/${customization}/${customization}.build
		customize
		exit 0 ;;

	"emulate") 
		emulate $image
		exit 0 ;;

	"prepare") 
		image=${customization}-${arch}-${device}-$(date "+%Y-%m-%d").img
		prepare_img $image
		exit 0 ;;

	"bootstrap") 
		bootstrap_img
		exit 0 ;;

	"tune") 
		tunning_img
		exit 0 ;;

	"compress") 
		zip $2.zip $2
		exit 0 ;;

	"burn") 
		dd bs=1M if=$2 of=$3 status=progress
		exit 0 ;;

	"mount") 
		mount_img $image
		exit 0 ;;

	"umount") 
		umount_img $image
		exit 0 ;;

esac
