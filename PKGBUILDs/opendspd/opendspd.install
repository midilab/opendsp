#!/bin/bash

set -e

#opendspd install
opendsp_passwd=opendsp

useradd -m -G audio,video,uucp,lock,tty opendsp
passwd opendsp <<EOF
$(($opendsp_passwd))
EOF

# +depends
# common: git
# alsa: alsa-firmware alsa-lib alsa-plugins alsa-utils
# x11: xf86-video-fbdev xorg-server xorg-xinit xorg-server-utils xterm dwm dmenu x11vnc
# dev_env: base-devel python git premake3

# X11 needs config for script auto start
# config for normal users
#sudo vi /etc/X11/Xwrapper.config
#allowed_users = anybody
#needs_root_rights = yes
# xinitrc: exec dwm

# compile
git https://github.com/midilab/opendsp.git
#git checkout development
