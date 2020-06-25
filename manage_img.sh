#!/bin/bash 
# dependency: psmisc wget bsdtar 
# example to manage a OpenDSP image for armv7 version of raspberry pi3/pi2
# ./manage_img.sh mount platform/armv7/raspberry_pi opendsp-...img
# ./manage_img.sh umount platform/armv7/raspberry_pi /dev/loop0
# ./manage_img.sh create platform/armv7/raspberry_pi 

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
				samba cpupower parted openbox create_ap
	
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
	chroot opendsp echo -ne "opendspd\nopendspd\n" | smbpasswd -a -s opendsp || true

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
	chroot opendsp smbpasswd -a opendsp -n

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

case $action in
	"create") 
		device=${2##*/}
		image_name=opendsp_${device}-$(date "+%Y-%m-%d").img
		prepare_img $image_name
		install_img
		install_opendsp
		tunning_img
		exit 0 ;;
	"install") 
		install_img
		exit 0 ;;
	"install_opendsp") 
		install_opendsp
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
		mount_img $target
		exit 0 ;;
	"umount") 
		umount_img $target
		exit 0 ;;
esac

echo "please chose mount or umount for an action"
