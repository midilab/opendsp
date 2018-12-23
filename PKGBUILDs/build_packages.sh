#!/bin/bash

set -e

sudo pacman -Syyu

# depends: base-devel git cmake
declare -a package=("mididings-git" "lv2-git" "ganv-git" "lilv-git" "raul-git" "serd-git" "suil-git" "ingen-git" "jamrouter-git" "mod-ttymidi" "distrho-lv2-git" "midifilter.lv2-git" "fabla-git" "drmr-falktx-git" "swh-lv2-git" "zam-plugins-git" "dpf-plugins-lv2-git" "openav-luppp-git" "mixxx" "linux-raspberrypi-rt-opendsp" "linux-raspberrypi-rt-opendsp-headers" "opendspd")

# lets get some memory space for compile process
if [ ! -f "/swapfile" ]
then
	sudo fallocate -l 512M /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
fi

sudo swapon /swapfile || true

for i in "${package[@]}"
do
   cd "$i"
   echo "building $i"
   rm -rf src/ pkg/ *.tar.xz
   makepkg -sci
   cp *.tar.xz ../../packages/armv7/ 
   cd ..
done

sudo swapoff -a
sudo rm -f /swapfile
