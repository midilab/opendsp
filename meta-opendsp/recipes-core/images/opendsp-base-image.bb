SUMMARY = "OpenDSP base with opendspd, user data partition and readonly rootfs."
LICENSE = "MIT"

inherit core-image

# user setup
inherit extrausers

# default password: opendspd
# md5 based
# openssl passwd -1 "opendspd"
DEFAULT_PASSWD = '\$1\$dEZC2DzA\$VHF1NAp2zij2ercxuiiOy0'
EXTRA_USERS_PARAMS = " \
	usermod -p '${DEFAULT_PASSWD}' root; \
    useradd -m -G audio,video,uucp,tty -p '${DEFAULT_PASSWD}' opendsp; \
"

IMAGE_FEATURES:remove = "splash"
EXTRA_IMAGE_FEATURES += " ssh-server-openssh package-management"

# all opendsp ecosystem specific required packages
IMAGE_INSTALL += "opendspd sudo boost rtmidi liblo python3 python3-pip python3-setuptools python3-pyliblo python3-cython python3-decorator python3-wheel python3-installer python3-appdirs python3-certifi python3-packaging python3-pillow python3-psutil python3-pyparsing python3-pyserial python3-six python3-tornado python3-cffi python3-jack-client python3-rtmidi python3-mididings pyxdg jack-dev jack-server jack-utils jack-src alsa-lib alsa-tools alsa-plugins alsa-topology-conf alsa-utils a2jmidid mpg123 parted cpupower wget"

# x env
IMAGE_INSTALL += "xserver-xorg xorg-minimal-fonts xinit xauth x11vnc rxvt-unicode xdotool openbox"
# xorg-server xorg-xinit xorg-server-common noto-fonts xorg-server-xvfb 
#IMAGE_INSTALL_append = " packagegroup-core-x11 \
# "

# missing: create_ap, xvfb, novnc
# missing opendsp: ecasound, tint2, patchage, qjackctl

IMAGE_LINGUAS = "en-us"

SDIMG_ROOTFS_TYPE = "ext4"
IMAGE_FSTYPES = "wic"
#IMAGE_FSTYPES = "wic ext4.gz"

# To make the image read only, uncomment the following line
IMAGE_FEATURES += "read-only-rootfs"

# specific board setup. use machine var for dinamyc require
require raspberrypi.inc

do_opendsp_rootfs_post () {
	# X11 needs config for session control
	echo "allowed_users = anybody" >> ${IMAGE_ROOTFS}/etc/X11/Xwrapper.config
	echo "needs_root_rights = yes" >> ${IMAGE_ROOTFS}/etc/X11/Xwrapper.config

	# xinitrc
	echo "[[ -f ~/.Xresources ]] && xrdb ~/.Xresources" > ${IMAGE_ROOTFS}/home/opendsp/.xinitrc
	echo "exec openbox-session" >> ${IMAGE_ROOTFS}/home/opendsp/.xinitrc

	# allow x11 forward for plugmod ingen edit modules
	echo "X11Forwarding yes" >> ${IMAGE_ROOTFS}/etc/ssh/sshd_config
	echo "PermitUserEnvironment yes" >> ${IMAGE_ROOTFS}/etc/ssh/sshd_config
	mkdir -p ${IMAGE_ROOTFS}/home/opendsp/.ssh/
	echo "export XAUTHORITY=/tmp/.Xauthority" >> ${IMAGE_ROOTFS}/home/opendsp/.ssh/environment
	echo "export XAUTHORITY=/tmp/.Xauthority" >> ${IMAGE_ROOTFS}/home/opendsp/.profile
	
	# create a place for x11vnc data to live on
	mkdir -p ${IMAGE_ROOTFS}/home/opendsp/.vnc/

	# allows ddns to find us
	#sed -i 's/#hostname/hostname/' ${IMAGE_ROOTFS}/etc/dhcpcd.conf

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