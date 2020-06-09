#!/bin/bash

set -e

sudo pacman -Syyu

sudo pacman -S base-devel cmake git

declare -a rt_kernels=("linux-raspberrypi-rt-opendsp" "linux-odroid-xu3-rt-opendsp")

declare -a opendsp_base=("mididings-git" "mod-ttymidi" "jamrouter-git" "python-wiringpi-git" "input2midi" "novnc" "python-rtmidi" "opendspd")

declare -a opendsp_audio=("raul-git" "ingen-git" "distrho-lv2-git" "midifilter.lv2-git" "non-daw-git" "klystrack-git" "dpf-plugins-git" "swh-lv2-git" "zam-plugins-git" "fabla-git" "drmr-falktx-git" "mod-sooper-looper-lv2" "opendsp-audio-modular")

declare -a opendsp_video=("sdl2-rpi" "mesa-rpi" "mesa-rpi-git" "lebiniou3" "lebiniou3-data" "processing" "omxplayer" "vlc" "puredata")

pack() {
   local -n packs=$1
   echo "BUILDING PACKS..."
   for i in "${packs[@]}"
   do
      cd "$i"
      echo "building $i"
      rm -rf src/ pkg/ *.tar.xz
      makepkg -sci
      cp *.tar.xz ../../packages/armv7/ 
      cd ..
   done
}

# lets get some memory space for compile process
if [ ! -f "/swapfile" ]
then
	sudo fallocate -l 512M /swapfile
	sudo chmod 600 /swapfile
	sudo mkswap /swapfile
fi

sudo swapon /swapfile || true

# start pack
#pack rt_kernels
#pack opendsp_base
pack opendsp_audio

sudo swapoff -a
sudo rm -f /swapfile
