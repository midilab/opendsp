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

set -e

action=$1
arch=$2
device=$3
image=$4

loop_device=''

# sdcard partition layout
sector_start=-1
declare -a partition_type
declare -a partition_size
declare -a partition_label
declare -a partition_mnt
filesystem_image=''

# throws all output to log file, except those on stdout 7
# save a copy of current stdout
#exec 7>&1 
#exec > "${BUILDER_PATH}/build/log.txt"
#exec  > "${BUILDER_PATH}/build/log.txt" 2>&1 
#exec &> "${BUILDER_PATH}/build/log.txt"

print() {
	string=$1	
	#echo "$string" >&7
}

#
# Platform create script
#
script="${BUILDER_PATH}/platforms/${arch}/${device}"
if [ ! -f "$script" ]
then
	echo "$0: platform script '${script}' not found."
	exit -1
fi

# import platform specific create script
source ${script}

#
# Opendsp create generic functions
install_opendsp() {
			
	echo "opendsp" > opendsp/etc/hostname
	echo "127.0.0.1 opendsp" >> opendsp/etc/hosts
	
	echo "" > opendsp/etc/motd
	cat <<EOF > opendsp/etc/issue


 ██████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗██████╗ 
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║  ██║███████╗██████╔╝
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔═══╝ 
╚██████╔╝██║     ███████╗██║ ╚████║██████╔╝███████║██║     
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝     

EOF

	# base dependencies for opendsp
	chroot opendsp pacman -S sudo xorg-server xorg-xinit xorg-server-common \
				xorg-server-xvfb rxvt-unicode x11vnc alsa-firmware alsa-lib \
				alsa-plugins alsa-utils python-setuptools python-pip \
				liblo python-pyliblo cython python-decorator python-appdirs \
				python-certifi python-packaging python-pillow python-psutil \
				python-pyparsing python-pyserial python-six python-tornado \
				python-virtualenv python-jack-client jack xdotool \
				samba cpupower parted openbox create_ap --noconfirm
	
	# add default opendsp user and setup his environment
	chroot opendsp useradd -m -G audio,video,uucp,lock,tty opendsp
	
	# change pass
	chroot opendsp sh -c "echo 'opendsp:opendspd' | chpasswd"
	
	# X11 needs config for session control
	echo "allowed_users = anybody" >> opendsp/etc/X11/Xwrapper.config
	echo "needs_root_rights = yes" >> opendsp/etc/X11/Xwrapper.config

	# xinitrc
	echo "[[ -f ~/.Xresources ]] && xrdb ~/.Xresources" > opendsp/home/opendsp/.xinitrc
	echo "exec openbox-session" >> opendsp/home/opendsp/.xinitrc

	# allow x11 forward for plugmod ingen edit modules
	echo "X11Forwarding yes" >> opendsp/etc/ssh/sshd_config
	echo "PermitUserEnvironment yes" >> opendsp/etc/ssh/sshd_config
	mkdir opendsp/home/opendsp/.ssh/
	echo "export XAUTHORITY=/tmp/.Xauthority" >> opendsp/home/opendsp/.ssh/environment
	echo "export XAUTHORITY=/tmp/.Xauthority" >> opendsp/home/opendsp/.profile
	
	# create a place for x11vnc data to live on
	mkdir -p opendsp/home/opendsp/.vnc/

	# allows ddns to find us
	sed -i 's/#hostname/hostname/' opendsp/etc/dhcpcd.conf

	# set sudo permition to enable opendspd changes realtime priority of process
	echo "opendsp ALL=(ALL) NOPASSWD: ALL" >> opendsp/etc/sudoers

	# set cpu for performance mode
	sed -i '/governor/d' opendsp/etc/default/cpupower
	echo "governor='performance'" >> opendsp/etc/default/cpupower
	chroot opendsp systemctl enable cpupower
	# get a better swappiness for realtime environment
	echo "vm.swappiness=10" >> opendsp/etc/sysctl.conf

	# set realtime environment for DSPing
	echo "@audio 	- rtprio 	99" >> opendsp/etc/security/limits.conf
	echo "@audio 	- memlock 	unlimited" >> opendsp/etc/security/limits.conf
	
	# disable some services
	#chroot opendsp systemctl disable systemd-random-seed || true
	#chroot opendsp systemctl enable avahi-daemon
	#chroot opendsp systemctl disable cron
	#chroot opendsp systemctl disable rsyslog
	#chroot opendsp systemctl disable ntp
	#chroot opendsp systemctl disable triggerhappy
	#chroot opendsp systemctl disable serial-getty@ttyAMA0.service
	#chroot opendsp systemctl disable getty@tty1.service
	
	# newer archlinux versions need to generate ssh keys by our own
	chroot opendsp ssh-keygen -A

	# setup samba
	#chroot opendsp echo -ne "opendspd\nopendspd\n" | smbpasswd -a -s opendsp || true
	chroot opendsp bash -c 'echo -ne "opendspd\nopendspd\n" | smbpasswd -a -s opendsp' || true

	cat <<EOF >> opendsp/etc/samba/smb.conf
[global]
  workgroup = OpenDSPGroup
  server string = "Opendsp user data"
  passdb backend = tdbsam
  load printers = no
  printing = bsd
  printcap name = /dev/null
  disable spoolss = yes
  show add printer wizard = no
  security = user

[data]
  comment = OpenDSP user data
  valid users = opendsp
  path = /home/opendsp/data
  writable = yes
  printable = no
  public = no
  create mask = 0644
  directory mask = 0755
EOF

	# enable service at boot time
	chroot opendsp systemctl enable smb
	chroot opendsp systemctl enable nmb	

	# setup samba share for user data over readolny fs
	cat <<EOF >> opendsp/etc/fstab
# samba fix for read only environment
tmpfs           /var/cache/samba tmpfs   defaults,noatime,mode=0755      0       0
tmpfs           /var/lib/samba   tmpfs   defaults,noatime,mode=0755      0       0
EOF
	# run for the first time to create dir structure
	# we need to run it on first boot for later read-only main partition usage of samba
	#chroot opendsp systemctl start smb
	chroot opendsp /usr/bin/smbd --foreground --no-process-group &
	#chroot opendsp systemctl start nmb	
	chroot opendsp /usr/bin/nmbd --foreground --no-process-group &
	kill -9 `pgrep nmbd` || true
	kill -9 `pgrep smbd` || true
	# add opendsp user
	chroot opendsp smbpasswd -a opendsp -n
	# set opendsp default password
	#chroot opendsp bash -C 'echo -ne "opendspd\nopendspd\n" | smbpasswd -a -s opendsp'
	chroot opendsp bash -c 'echo -ne "opendspd\nopendspd\n" | smbpasswd -a -s opendsp'

	# little hack that enable us to start samba on read only file system
	mv opendsp/var/cache/samba opendsp/var/cache/samba.cp
	mkdir -p opendsp/var/cache/samba
	mv opendsp/var/lib/samba opendsp/var/lib/samba.cp
	mkdir -p opendsp/var/lib/samba
	cat <<EOF >> opendsp/etc/systemd/system/sambafix.service
[Unit]
Description=Samba Service
After=remote-fs.service

[Service]
Type=simple
User=root
Group=root
WorkingDirectory=/home/opendsp/
ExecStart=/bin/sh -c '/usr/bin/cp -Rf /var/cache/samba.cp/* /var/cache/samba/; /usr/bin/cp -Rf /var/lib/samba.cp/* /var/lib/samba/'

[Install]
WantedBy=multi-user.target
EOF
	chroot opendsp systemctl enable sambafix || true

	# setup create_ap wifi access point
	cat <<EOF >> opendsp/etc/create_ap.conf
CHANNEL=default
GATEWAY=10.0.0.1
WPA_VERSION=2
ETC_HOSTS=0
DHCP_DNS=gateway
NO_DNS=0
HIDDEN=0
MAC_FILTER=0
MAC_FILTER_ACCEPT=/etc/hostapd/hostapd.accept
ISOLATE_CLIENTS=0
SHARE_METHOD=nat
IEEE80211N=0
IEEE80211AC=0
HT_CAPAB=[HT40+]
VHT_CAPAB=
DRIVER=nl80211
NO_VIRT=0
COUNTRY=
FREQ_BAND=2.4
NEW_MACADDR=
DAEMONIZE=0
NO_HAVEGED=0
WIFI_IFACE=wlan0
INTERNET_IFACE=eth0
SSID=OpenDSP
PASSPHRASE=opendspd
USE_PSK=0
EOF

	chroot opendsp systemctl enable create_ap

	# Xsession setup
	cat <<EOF >> opendsp/home/opendsp/.Xresources
! Dracula Xresources palette
*.foreground: #F8F8F2
*.background: #282A36
*.color0:     #000000
*.color8:     #4D4D4D
*.color1:     #FF5555
*.color9:     #FF6E67
*.color2:     #50FA7B
*.color10:    #5AF78E
*.color3:     #F1FA8C
*.color11:    #F4F99D
*.color4:     #BD93F9
*.color12:    #CAA9FA
*.color5:     #FF79C6
*.color13:    #FF92D0
*.color6:     #8BE9FD
*.color14:    #9AEDFE
*.color7:     #BFBFBF
*.color15:    #E6E6E6

!URxvt.font:xft:Lemon:pixelsize=14
!URxvt.boldFont:xft:Lemon:bold:pixelsize=14
!URxvt.italicfont:xft:Lemon:italic:pixelsize=14
!URxvt.bolditalicFont:xft:Lemon:bold:italic:pixelsize=14
!URxvt*letterSpace: 1
!URxvt*allow_bold: true
!URxvt.font: xft:ubuntu mono:pixelsize=16
URxvt.font: xft:Bitstream Vera Sans Mono:pixelsize=16
! URXVT FONT SETTINGS
!------------------------------------------------
Xft.autohint: true
Xft.antialias: true
Xft.hinting: true
Xft.hintstyle: hintslight
Xft.rgba: rgb
Xft.lcdfilter: lcddefault
! URXVT ENABLE LINK SUPPORT
!------------------------------------------------
URxvt.perl-lib: /home/luca/Documenti/perl/
URxvt.perl-ext-common: default,matcher,clipboard
!tabbed
URxvt.matcher.button: 1
URxvt.perl-ext: default
URxvt.keysym.M-u: perl:url-select:select_next
URxvt.url-select.launcher: /usr/bin/firefox
URxvt.url-select.underline: true
!disable the fucking bell
URxvt.insecure: false
! URXVT COPY PASTE SHORTCUTS
!------------------------------------------------
URxvt.iso14755: False
URxvt.keysym.Shift-Control-C: eval:selection_to_clipboard
URxvt.keysym.Shift-Control-V: eval:paste_clipboard
!URxvt.keysym.Shift-Control-C: perl:clipboard:copy
!URxvt.keysym.Shift-Control-V: perl:clipboard:paste
!URxvt.keysym.M-c: perl:clipboard:copy
!URxvt.keysym.M-v: perl:clipboard:paste
!URxvt.clipboard.autocopy: true
!URxvt.keysym.M-c: perl:clipboard:copy
!URxvt.keysym.M-v: perl:clipboard:paste
!URxvt.keysym.M-C-v: perl:clipboard:paste_escaped
! URXVT SCROLLBAR AND CURSOR STYLE
!------------------------------------------------
URxvt*saveLines: 300000
URxvt.scrollBar: false
!URxvt*scrollstyle: plain
URxvt*cursorBlink: true
URxvt*cursorUnderline: true

! URXVT TABS
!------------------------------------------------
URxvt.tabbedex.autohide: yes
URxvt.tabbedex.tabbar-fg: 2
URxvt.tabbedex.tabbar-bg: 0
URxvt.tabbedex.tab-fg: 10
URxvt.tabbedex.tab-bg: 0
URxvt.tabbedex.title: yes
URxvt.tabbedex.new-button: no
EOF

	# setup sane permitions
	chroot opendsp chown -R opendsp:opendsp /home/opendsp/			
}

install_img() {
		
	if [ ! -d "opendsp/lost+found" ]
	then
		echo "no lost found"
	fi

	# download or use it local?
	if [ ! -f "$filesystem_image" ]
	then
		# download it!
		wget "${RELEASE_DOWNLOAD_URL}/${filesystem_image}"
	fi
	# install filesystem_image
	bsdtar -xvpf $filesystem_image -C opendsp || true

	# any post install action to be done?
	post_filesystem_install

	retVal=-1
	while [ $retVal -ne 0 ]; do
		chroot opendsp pacman-key --init || true
		retVal=$?    
	done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		chroot opendsp pacman-key --populate archlinuxarm || true
		retVal=$?  
	done

	#retVal=-1
	#while [ $retVal -ne 0 ]; do
	#	chroot opendsp pacman -Syyu --noconfirm || true
	#	retVal=$?
	#done

	retVal=-1
	while [ $retVal -ne 0 ]; do
		chroot opendsp ssh-keygen -A || true
		retVal=$?  
	done

}	

prepare_img() {

	image_name=$1
	image_size=0

    for size in ${partition_size[@]}; do
		image_size=$((image_size+size))
    done
	image_size=$((image_size+64))
	
	dd if=/dev/zero of=$image_name  bs=1M  count=$image_size
		
	# creating partition table
    for i in ${!partition_type[@]}; do
        # one by one
		size=${partition_size[$i]}		
		fdisk $image_name <<EOF
n



+$(($size))M
w
EOF

		# change type?
		if [ ${partition_type[$i]} == "fat" ]; then
			fdisk $image_name <<EOF
t
$(($i+1))
c
w
EOF
		fi

    done

	# move first partition sector to sector_start if it is defined
	if [ $sector_start -ge 0 ]; then
		fdisk $image_name <<EOF
x
b
1
$(($sector_start))
r
w
EOF
	fi

	# prepare img
	loop_device="$(losetup --show -f -P "$image_name")"

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
	fdisk -l $image_name	
}

mount_img() {
	
	image_name=$1
	
	if [ -d "opendsp/" ]; then
    	echo "file system mounted"
		return
	fi

	if [ "$loop_device" == "" ]; then
		# mount on loop loop_device
		loop_device="$(losetup --show -f -P "$image_name")"
	fi

	# mounting first root /
    for i in ${!partition_mnt[@]}; do
		if [ ${partition_mnt[$i]} == "/" ]; then
			p=$((i+1))
			mkdir -p opendsp/
			mount -v -t ext4 -o sync "${loop_device}p${p}" opendsp${partition_mnt[$i]}
		fi
	done

	# mounting partitions
    for i in ${!partition_mnt[@]}; do
		# already mounted above
		if [ ${partition_mnt[$i]} == "/" ]; then
			continue
		fi
		p=$((i+1))
        # one by one
		mkdir -p opendsp${partition_mnt[$i]}
		if [ ${partition_type[$i]} == "fat" ]; then
			mount -v -t vfat -o sync "${loop_device}p${p}" opendsp${partition_mnt[$i]}
		elif [ ${partition_type[$i]} == "ext4" ]; then
			mount -v -t ext4 -o sync "${loop_device}p${p}" opendsp${partition_mnt[$i]}
		fi
	done

	# good idea to have those mounted as we chroot in
	mkdir -p opendsp/proc
	mkdir -p opendsp/sys
	mkdir -p opendsp/dev/pts
	mount -t proc /proc opendsp/proc
	mount -o bind /sys opendsp/sys
	mount -o bind /dev opendsp/dev
	mount -o bind /dev/pts opendsp/dev/pts
	
	# prepare for chroot using qemu
	mkdir -p opendsp/usr/bin
	cp /usr/bin/qemu-arm-static opendsp/usr/bin/	
	
	# copy temporarly our resolv.conf to get internet connection
	mkdir -p opendsp/run/systemd/resolve/
	cp /etc/resolv.conf opendsp/run/systemd/resolve/
	
}

umount_img() {

	image_name=$1	
	
	if [ ! -d "opendsp/" ]; then
    	echo "file system not mounted"
		return
	fi

	# just in case, sometimes they can lock /dev/
	kill -9 `pgrep gpg-agent` || true
	kill -9 `pgrep pacman` || true
	 
	# remove any installed packages on /var/cache/pacman/pkg/
	rm opendsp/var/cache/pacman/pkg/* || true

	# remove our systemd resolv.conf
	rm -rf opendsp/run/systemd/ || true

	# after all remove qemu
	rm opendsp/usr/bin/qemu-arm-static || true

	sync

	retVal=-1
	while [ $retVal -ne 0 ]; do
		umount --recursive opendsp/ || true 
		retVal=$?
	done

	rm -rf opendsp || true

	# release the image loop device
	if [ "$loop_device" == "" ]; then
		# release all loopdevices
		losetup -D
	else
		losetup -d $loop_device
	fi
}

# operates everything from build path
cd $BUILDER_PATH/build/

case $action in
	"create") 
		image=opendsp-${arch}-${device}-$(date "+%Y-%m-%d").img
		print "preparing image..."
		prepare_img $image
		mount_img $image
		print "installing image..."
		install_img
		#print "tunning image..."
		#tunning_img
		#print "installing opendsp..."
		#install_opendsp
		#print "image ready to go into sdcard!"
		exit 0 ;;
	"prepare") 
		image=opendsp-${arch}-${device}-$(date "+%Y-%m-%d").img
		prepare_img $image
		exit 0 ;;
	"install") 
		install_img
		exit 0 ;;
	"tune") 
		tunning_img
		exit 0 ;;
	"install_opendsp") 
		install_opendsp
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
