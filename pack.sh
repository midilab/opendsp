#!/bin/bash

set -e

# depends: base-devel git
declare -a package=("mididings-git" "mod-ttymidi" "opendspd" "mod-host-git" "distrho-lv2-git" "midifilter.lv2-git" "fabla-git" "mda-lv2-git" "drmr-falktx-git" "swh-lv2-git" "zam-plugins-git" "projectm-jack" "linux-raspberrypi-rt-opendsp")

# lets get some memory space for compile process
sudo fallocate -l 512M /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

cd PKGBUILDs/

for i in "${package[@]}"
do
   cd "$i"
   echo "building $i"
   #makepkg -isc
   makepkg -si --noconfirm | true
   cp *.tar.xz ../../packages/armv7/ | true
   cd ..
done

sudo swapoff -a
sudo rm -f /swapfile
