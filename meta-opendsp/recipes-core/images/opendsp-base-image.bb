SUMMARY = "OpenDSP base with opendspd, user data partition and readonly rootfs."
LICENSE = "MIT"

#
# image setup
#
inherit core-image

IMAGE_FEATURES:remove = "splash"
EXTRA_IMAGE_FEATURES += " ssh-server-openssh package-management"

# all opendsp ecosystem specific required packages
IMAGE_INSTALL += "opendspd sudo boost rtmidi liblo python3 python3-pip python3-setuptools python3-pyliblo python3-cython python3-decorator python3-wheel python3-installer python3-appdirs python3-certifi python3-packaging python3-pillow python3-psutil python3-pyparsing python3-pyserial python3-six python3-tornado python3-cffi python3-jack-client python3-rtmidi python3-mididings pyxdg jack-dev jack-server jack-utils jack-src alsa-lib alsa-tools alsa-plugins alsa-topology-conf alsa-utils a2jmidid mpg123 parted cpupower wget"

# x env
IMAGE_INSTALL += "xserver-xorg xserver-xorg-xvfb xorg-minimal-fonts xinit xauth x11vnc rxvt-unicode xdotool openbox"
#IMAGE_INSTALL += "packagegroup-core-x11"

# networking
IMAGE_INSTALL += "samba"

# missing: create_ap, novnc jamrouter mod-ttymidi tint2

IMAGE_LINGUAS = "en-us"

SDIMG_ROOTFS_TYPE = "ext4"
IMAGE_FSTYPES = "wic"
#IMAGE_FSTYPES = "wic ext4.gz"

# To make the image read only, uncomment the following line
IMAGE_FEATURES += "read-only-rootfs"

#
# board setup
#
# specific board setup. use machine var for dinamyc require
require raspberrypi.inc

#
# user setup
#
inherit extrausers
# md5 based
# openssl passwd -1 "opendspd"
DEFAULT_PASSWD = '\$1\$dEZC2DzA\$VHF1NAp2zij2ercxuiiOy0'
EXTRA_USERS_PARAMS = " \
	usermod -p '${DEFAULT_PASSWD}' root; \
    useradd -m -G audio,video,uucp,tty -p '${DEFAULT_PASSWD}' opendsp; \
"

#
# services
#
inherit systemd

# create_ap.service
SYSTEMD_SERVICE:${PN} += "opendsp.service"
SYSTEMD_AUTO_ENABLE = "enable"

#
# post tunning
#
do_opendsp_rootfs_post () {

	echo "opendsp" > ${IMAGE_ROOTFS}/etc/hostname
	cat <<EOF > ${IMAGE_ROOTFS}/etc/issue


 ██████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗██████╗ 
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║  ██║███████╗██████╔╝
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔═══╝ 
╚██████╔╝██║     ███████╗██║ ╚████║██████╔╝███████║██║     
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝     

EOF

	# X11 needs config for session control
	echo "allowed_users = anybody" >> ${IMAGE_ROOTFS}/etc/X11/Xwrapper.config
	echo "needs_root_rights = yes" >> ${IMAGE_ROOTFS}/etc/X11/Xwrapper.config

	# xinitrc
	echo "[[ -f ~/.Xresources ]] && xrdb ~/.Xresources" > ${IMAGE_ROOTFS}/home/opendsp/.xinitrc
	echo "exec openbox-session" >> ${IMAGE_ROOTFS}/home/opendsp/.xinitrc

	# allow x11 forward for plugmod ingen edit modules
	echo "X11Forwarding yes" >> ${IMAGE_ROOTFS}/etc/ssh/sshd_config
	echo "PermitUserEnvironment yes" >> ${IMAGE_ROOTFS}/etc/ssh/sshd_config
	
	# create a place for x11vnc data to live on
	mkdir -p ${IMAGE_ROOTFS}/home/opendsp/.vnc/

	# set sudo permition to enable opendspd changes realtime priority of process
	echo "opendsp ALL=(ALL) NOPASSWD: ALL" >> ${IMAGE_ROOTFS}/etc/sudoers

	# set cpu for performance mode
	#sed -i '/governor/d' ${IMAGE_ROOTFS}/etc/default/cpupower
	#echo "governor='performance'" >> ${IMAGE_ROOTFS}/etc/default/cpupower
	# get a better swappiness for realtime environment
	echo "vm.swappiness=10" >> ${IMAGE_ROOTFS}/etc/sysctl.conf

	# set realtime environment for DSP
	#echo "@audio 	- rtprio 	99" >> ${IMAGE_ROOTFS}/etc/security/limits.conf
	#echo "@audio 	- memlock 	unlimited" >> ${IMAGE_ROOTFS}/etc/security/limits.conf

	# samba
	cat <<EOF > ${IMAGE_ROOTFS}/etc/samba/smb.conf
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

	# setup create_ap wifi access point
	cat <<EOF >> ${IMAGE_ROOTFS}/etc/create_ap.conf
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

	# changing samba file share service password
	#echo -ne "$PASSWORD\n$PASSWORD\n" | smbpasswd -a -s opendsp
	# chaging vnc virtual desktop service password
	#x11vnc -storepasswd $PASSWORD ${IMAGE_ROOTFS}/home/opendsp/.vnc/passwd
	# chaging wifi access point service connection password
	#sed -i "/PASSPHRASE/c\PASSPHRASE=$PASSWORD" ${IMAGE_ROOTFS}/etc/create_ap.conf

	# rm lost+found on data user partition
	#rm -r ${IMAGE_ROOTFS}/home/opendsp/data/lost+found
}

do_opendsp_image_post () {
	# set sane permitions
    chown -R opendsp ${IMAGE_ROOTFS}/home/opendsp/
    chgrp -R opendsp ${IMAGE_ROOTFS}/home/opendsp/
}

ROOTFS_POSTPROCESS_COMMAND += "do_opendsp_rootfs_post; "
IMAGE_POSTPROCESS_COMMAND += "do_opendsp_image_post; "