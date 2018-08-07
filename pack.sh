#!/bin/bash

set -e

# depends: base-devel git
declare -a package=("linux-raspberrypi-rt-opendsp" "rtirq" "mididings-git" "ttymidi" "opendspd" "csound" "gmm" "suil-git" "ganv-git" "raul-git" "lv2-git" "ntk-git" "distrho-lv2-git" "midifilter.lv2-git" "calf-git" "fabla-git" "mda-lv2-git" "drmr-falktx-git" "swh-lv2-git" "zam-plugins-git" "projectm-jack")

cd PKGBUILDs/


for i in "${package[@]}"
do
   cd "$i"
   #makepkg -isc
   makepkg -is
   cd ..
done


