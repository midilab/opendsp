SUMMARY = "OpenDSP base with opendspd, user data partition and readonly rootfs."
LICENSE = "MIT"

inherit core-image

# user setup
inherit extrausers

# default password: opendspd
# mkpasswd -m sha256crypt opendspd
DEFAULT_PASSWD = '$5$wPSInRMB.6nSC7ZT$7LEnd/S3vhX5YWR9GhBanZZKeYE7ytQwgSA0RY1Xic5'

# usermod -p '${DEFAULT_PASSWD}' root
EXTRA_USERS_PARAMS = " \
    useradd -m -G audio,video,uucp,tty -p '${DEFAULT_PASSWD}' opendsp \
"

# remove only for raspberry?
#MACHINE_FEATURES:remove = "bluetooth"
IMAGE_FEATURES += "empty-root-password allow-empty-password"
IMAGE_FEATURES:remove = "splash bluetooth"
#IMAGE_FEATURES += "package-management"
EXTRA_IMAGE_FEATURES += " ssh-server-openssh package-management"

IMAGE_INSTALL += "opendspd sudo boost rtmidi liblo python3 python3-pip python3-setuptools python3-pyliblo python3-cython python3-decorator python3-wheel python3-installer python3-appdirs python3-certifi python3-packaging python3-pillow python3-psutil python3-pyparsing python3-pyserial python3-six python3-tornado python3-cffi python3-jack-client python3-rtmidi python3-mididings pyxdg jack-dev jack-server jack-utils jack-src alsa-lib alsa-tools alsa-plugins alsa-topology-conf alsa-utils a2jmidid mpg123 parted cpupower wget"

# x env
IMAGE_INSTALL += "xserver-xorg xorg-minimal-fonts xinit x11vnc rxvt-unicode xdotool openbox"
# xorg-server xorg-xinit xorg-server-common noto-fonts xorg-server-xvfb 
#IMAGE_INSTALL_append = " packagegroup-core-x11 \
# libxcursor libxcursor-dev \
# libxinerama libxinerama-dev \
# "

# non working recipes
# python3-python-osc python3-virtualenv 

# missing: create_ap, xvfb, novnc, opendspd
# missing opendsp: ecasound, tint2, patchage, qjackctl

IMAGE_LINGUAS = "en-us"

SDIMG_ROOTFS_TYPE = "ext4"
IMAGE_FSTYPES = "wic ext4.gz"

# ...
do_systemd_network () {
	install -d ${IMAGE_ROOTFS}${sysconfdir}/systemd/network
	cat << EOF > ${IMAGE_ROOTFS}${sysconfdir}/systemd/network/10-en.network
[Match]
Name=en*

[Network]
DHCP=yes
EOF

	cat << EOF > ${IMAGE_ROOTFS}${sysconfdir}/systemd/network/11-eth.network
[Match]
Name=eth*

[Network]
DHCP=yes
EOF
}

#addtask do_systemd_network after do_image_wic before do_image_complete

