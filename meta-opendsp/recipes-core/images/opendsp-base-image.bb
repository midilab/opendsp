SUMMARY = "OpenDSP base with opendspd, user data partition and readonly rootfs."
LICENSE = "MIT"

#
# image setup
#
inherit core-image

IMAGE_FEATURES:remove = "splash dropbear"
EXTRA_IMAGE_FEATURES += " ssh-server-openssh package-management"

# all opendsp ecosystem specific required packages
IMAGE_INSTALL += " \
    shadow \
    opendspd \
    sudo \
    boost \
    rtmidi \
    rtirq \
    procps \
    liblo \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-pyliblo \
    python3-cython \
    python3-decorator \
    python3-wheel \
    python3-installer \
    python3-appdirs \
    python3-certifi \
    python3-packaging \
    python3-pillow \
    python3-psutil \
    python3-pyparsing \
    python3-pyserial \
    python3-six \
    python3-tornado \
    python3-cffi \
    python3-jack-client \
    python3-rtmidi \
    python3-mididings \
    pyxdg \
    jack-dev \
    jack-server \
    jack-utils \
    jack-src \
    jamrouter \
    fltk \
    fltk-src \
    alsa-lib \
    alsa-tools \
    alsa-plugins \
    alsa-topology-conf \
    alsa-utils \
    alsa-firmware \
    a2jmidid \
    mpg123 \
    parted \
    cpupower \
    wget \
    bash \
    util-linux \
    htop \
"

# Development environment?
#IMAGE_INSTALL += " gcc make cmake pkgconfig"

# Tools
IMAGE_INSTALL += " e2fsprogs-resize2fs"

# x env
IMAGE_INSTALL += " \
    xserver-xorg \
    xserver-common \
    xserver-xorg-xvfb \
    xf86-video-fbdev \
    xorg-minimal-fonts \
    xinit \
    xauth \
    xset \
    x11vnc \
    rxvt-unicode \
    xdotool \
    openbox \
    obconf \
"

# openGL support
IMAGE_INSTALL += " \
    mesa \
    libgles1-mesa \
    libgles2-mesa \
    libgles3-mesa \
    mesa-demos \
    libglu \
    libgl \
    libegl \
    glew \
"
# mesa mesa-dri-drivers mesa-gl
#IMAGE_INSTALL_append = " xserver-xorg-extension-glx xserver-xorg-video-modesetting "
#gsl xrandr
# none avaliable, but using intel drive we get accel done

# networking
IMAGE_INSTALL += " samba hostapd"

# setup opendsp ecosystem
IMAGE_INSTALL += " udev-rules-tty"
# missing: create_ap(use linux-router instead or only hostapd), novnc jamrouter mod-ttymidi tint2

# meta-dsp
IMAGE_INSTALL += " \
    lv2 \
    jalv \
    mda-lv2 \
    patchage \
    jc303 \
    jc303-lv2 \
    jc303-vst3 \
    gearmulator \
    gearmulator-lv2 \
    gearmulator-vst3 \
    distrho-ports-lv2 \
    distrho-ports-vst3 \
    distrho-ports-presets \
    dpf-plugins-standalone \
    dpf-plugins-lv2 \
    dpf-plugins-vst \
    ingen \
    ingen-standalone \
    carla \
"

# meta-video
IMAGE_INSTALL += " \
    projectm \
    projectm-presets-cream-of-the-crop \
"

IMAGE_LINGUAS = "en-us"

SDIMG_ROOTFS_TYPE = "ext4"
IMAGE_FSTYPES = "wic"

# yes we want read-only filesystem
IMAGE_FEATURES += " read-only-rootfs"

#
# board setup
#
# specific board setup. uses machine var for dinamyc require
require ${MACHINE}.inc

#
# user setup
#
inherit extrausers
# md5 based
# openssl passwd -1 "opendspd"
DEFAULT_PASSWD = '\$1\$dEZC2DzA\$VHF1NAp2zij2ercxuiiOy0'
EXTRA_USERS_PARAMS = " \
	usermod -p '${DEFAULT_PASSWD}' root; \
    useradd -m -G audio,video,uucp,tty,dialout -p '${DEFAULT_PASSWD}' opendsp; \
"

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
	echo "[[ -f ~/.Xresources ]] && xrdb ~/.Xresources" > ${IMAGE_ROOTFS}/etc/skel/.xinitrc
	echo "exec openbox-session" >> ${IMAGE_ROOTFS}/etc/skel/.xinitrc

	# allow x11 forward for plugmod ingen edit modules
	echo "X11Forwarding yes" >> ${IMAGE_ROOTFS}/etc/ssh/sshd_config
	echo "PermitUserEnvironment yes" >> ${IMAGE_ROOTFS}/etc/ssh/sshd_config

	# allow usage of x display from terminal and via x11 forward
	mkdir -p ${IMAGE_ROOTFS}/etc/skel/.ssh/
	echo "export XAUTHORITY=/tmp/.Xauthority" >> ${IMAGE_ROOTFS}/etc/skel/.ssh/environment
	echo "export XAUTHORITY=/tmp/.Xauthority" >> ${IMAGE_ROOTFS}/etc/skel/.profile

	# create a place for x11vnc data to live on
	mkdir -p ${IMAGE_ROOTFS}/etc/skel/.vnc/
	echo "" > ${IMAGE_ROOTFS}/etc/skel/.vnc/passwd

    # add this for TERM use xterm as default
    echo "export TERM=xterm-256color" >> ${IMAGE_ROOTFS}/etc/skel/.bashrc

	# set sudo permition to enable opendspd changes realtime priority of process
	echo "opendsp ALL=(ALL) NOPASSWD: ALL" >> ${IMAGE_ROOTFS}/etc/sudoers

    # get a better swappiness for realtime environment
	echo "vm.swappiness=10" >> ${IMAGE_ROOTFS}/etc/sysctl.conf

	# set realtime environment for DSP
	echo "@audio 	- rtprio 	95" >> ${IMAGE_ROOTFS}/etc/security/limits.conf
	echo "@audio 	- memlock 	unlimited" >> ${IMAGE_ROOTFS}/etc/security/limits.conf
	echo "@audio 	- nice 	-19" >> ${IMAGE_ROOTFS}/etc/security/limits.conf
	echo "@audio 	- nofile 	65536" >> ${IMAGE_ROOTFS}/etc/security/limits.conf
    sed -i 's/#DefaultLimitMEMLOCK.*/DefaultLimitMEMLOCK=infinity/' ${IMAGE_ROOTFS}/etc/systemd/system.conf
    sed -i 's/#DefaultLimitNOFILE.*/DefaultLimitNOFILE=65536/' ${IMAGE_ROOTFS}/etc/systemd/system.conf

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
}


do_opendsp_image_pre () {
	# set sane permitions
    chown -R opendsp ${IMAGE_ROOTFS}/home/opendsp/
    chgrp -R opendsp ${IMAGE_ROOTFS}/home/opendsp/
}

ROOTFS_POSTPROCESS_COMMAND += "do_opendsp_rootfs_post; "
#IMAGE_PREPROCESS_COMMAND += "do_opendsp_image_pre; "

# for user name resolution at chown and chgrp
DEPENDS += " shadow-native"
