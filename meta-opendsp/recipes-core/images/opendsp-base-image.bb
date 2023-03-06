SUMMARY = "OpenDSP base with opendspd, user data partition and readonly rootfs."
LICENSE = "MIT"

inherit core-image

# user setup
inherit extrausers

# default password: opendspd
# openssl passwd "yourpass"
DEFAULT_PASSWD = '$1$Xeuy69US$wbzoMuuqpcys4S1FSsHew1'
EXTRA_USERS_PARAMS = " \
	usermod -p '${DEFAULT_PASSWD}' root; \
    useradd -m -G audio,video,uucp,tty -p '${DEFAULT_PASSWD}' opendsp; \
"

#IMAGE_FEATURES += "empty-root-password allow-empty-password"
IMAGE_FEATURES:remove = "splash"
#IMAGE_FEATURES += "package-management"
EXTRA_IMAGE_FEATURES += " ssh-server-openssh package-management"

IMAGE_INSTALL += " opendspd sudo boost rtmidi liblo python3 python3-pip python3-setuptools python3-pyliblo python3-cython python3-decorator python3-wheel python3-installer python3-appdirs python3-certifi python3-packaging python3-pillow python3-psutil python3-pyparsing python3-pyserial python3-six python3-tornado python3-cffi python3-jack-client python3-rtmidi python3-mididings pyxdg jack-dev jack-server jack-utils jack-src alsa-lib alsa-tools alsa-plugins alsa-topology-conf alsa-utils a2jmidid mpg123 parted cpupower wget"

# x env
IMAGE_INSTALL += "xserver-xorg xorg-minimal-fonts xinit x11vnc rxvt-unicode xdotool openbox"
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
