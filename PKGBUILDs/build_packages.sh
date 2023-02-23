#!/bin/bash
# to solve ssl issues for download please:
# sudo timedatectl set-ntp true 
set -e

sudo pacman -Syu --noconfirm

sudo pacman -S base-devel cmake git meson --noconfirm

declare -a rt_kernels=("linux-raspberrypi-rt-opendsp" "linux-odroid-xu3-rt-opendsp")

declare -a opendsp_base=("jack" "jack-example-tools" "mod-ttymidi" "jamrouter-git" "python-wiringpi-git" "input2midi" "novnc" "opendspd" "opendsp-mods")

# klystrack-plus is on repo now! removed "klystrack-git" 
# no mma*? mirack?
declare -a opendsp_audio=("raul-git" "ingen-git" "fabla-git" "distrho-lv2-git" "non-daw-git" "dpf-plugins-git" "swh-lv2-git" "zam-plugins-git" "drmr-falktx-git" "mixxx" "sunvox" "mod-sooper-looper-lv2" "opendsp-audio-modular")

declare -a opendsp_video=("mesa-rpi" "mesa-rpi-git" "sdl2-rpi" "lebiniou3" "lebiniou3-data" "processing" "opendsp-mods-factory-video" "opendsp-video-processing")

pack() {
   local -n packs=$1
   echo "BUILDING PACKS..."
   for i in "${packs[@]}"
   do
      if [ ! -d "${i}" ]
      then
         continue
      fi
      cd "${i}"
      echo "building ${i}"
      rm -rf src/ pkg/ *.tar.xz
      makepkg -sci --noconfirm
      mv *.tar.xz ../packages/armv7/ 
      #makepkg --clean --nobuild --nodeps  --noextract
      cd ..
      rm -rf "${i}"/
   done
}

if [ ! -d "packages" ]
then
   mkdir -p packages/armv7
fi

# lets get some memory space for compile process
#if [ ! -f "/swapfile" ]
#then
#	sudo fallocate -l 512M /swapfile
#	sudo chmod 600 /swapfile
#	sudo mkswap /swapfile
#fi

#sudo swapon /swapfile || true

# start pack
#pack rt_kernels
pack opendsp_base
pack opendsp_audio
#pack opendsp_video

#sudo swapoff -a
#sudo rm -f /swapfile
