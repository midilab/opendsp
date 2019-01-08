 ██████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗██████╗ 
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║  ██║███████╗██████╔╝
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔═══╝ 
╚██████╔╝██║     ███████╗██║ ╚████║██████╔╝███████║██║     
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝     

Operational System for headless audio and video DSP computing, based on ArchLinux.

![Image of OpenDSP Plugmod and DX7  view](https://raw.githubusercontent.com/midilab/opendsp/master/doc/plugmod-opendsp.jpg)

The idea behind this project is to allows a computer, embeded or pc without monitor, to emulate and behave like the most common audio and video production expensive hardware gears on the market. All the interface is done via MIDI or OSC protocol. 

You can for example emulate a legendary Akai MPC or a Yamaha DX7 synthesizer, you can use it as as DJ system with or without vinyl timecode support. You can use it as a effect box and emulate classics like Roland Space Echo delay machine. You can use it as a mixing platform with support to the most common daily audio engeneering tools like compressors, limiters, expanders, multiband equalizers and so on...  

The opensource community gives you a very huge number of different applications that  

# Pre release

Images avaliable as pre-release. All the distro ecosystem are functional but the opendsp service are not ready for full MIDI/OSC user interface support. The final release will happen when we have opendsp service https://github.com/midilab/opendspd ready for final release.  

## OpenDSP Applications

plugmod: a multitrack plugin host, similar to old muse receptor hardware. Each track has dedicated channel strip with EQ, Sends and Audio processing plugin support. The number of tracks are limited to your hardware CPU horse power.
Its based on Ingen and Ecasound setup to support LV2 plugins.
Ingen:
Ecasound:
LV2 Plugins collection:

## Platform image downloads
 
* Raspberry 2 and 3 (32bits)  
With vc4 hardware acelerator support and 256mb video memory  

* Raspberry 2 and 3 (32bits) with hifiberry support  

* PiSound  

## Roadmap

* Get a full OpenDSP interface support for MIDI, OSC and keyboard.

* mix app: A Dj setup just like native instruments traktor, with support for vinyl timecode also.
Its based on Mixxx.

* vjing app: A Vj setup for video performances with effects  
