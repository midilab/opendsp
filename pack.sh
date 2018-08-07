#!/bin/bash

set -e

#calf-git
#drmr-falktx-git                 
#lv2-git
#rtirq     
#fabla-git                        
#mda-lv2-git  
#midifilter.lv2-git  
#projectm-jack
#zam-plugins-git
#distrho-lv2-git  
#linux-raspberrypi-rt-opendsp  
#ntk-git             
#swh-lv2-git

## declare an array variable
declare -a package=("mididings-git" "ttymidi" "opendspd" "csound" "gmm" "suil-git" "ganv-git" "raul-git")

cd PKGBUILDs/

## now loop through the above array
for i in "${package[@]}"
do
   cd "$i"
   # or do whatever with individual element of the array
   makepkg -isc
   cd ..
done


