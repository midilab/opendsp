OpenDSP
=======

OpenDSP is a headless-first Realtime Operational System designed for audio and video Digital Signal Processing on embedded devices such as Raspberry Pi.

[OpenDSP Daemon Service](https://github.com/midilab/opendspd) serves as a comprehensive framework for creating DSP devices that can seamlessly interface with any MIDI or OSC compliant device.

By combining the OpenDSP **OS** and **Service**, you gain the capability to emulate numerous expensive proprietary DSP machines or even develop your own customized DSP solution to cater to your specific requirements.
  
[Download Raspberry Pi2/3 Image!](https://github.com/midilab/opendsp/releases/download/v0.11.0/opendsp_0.11.0-raspberry_pi2_3.zip)    

Please check our [wiki](https://github.com/midilab/opendsp/wiki) for the latest documentation and tutorials.

OpenDSP is ideal for
--------------------

Musicians • DJs • Audio and Video Producers • Video Art Producers and Performers • Multimedia Interactive Instalations • Theatre Sound Technicians • DSP Students and Researches

A real-time kernel and a sub-set of opensource applications, plugins and tools makes OpenDSP vastly hackable for different kinda of DSP tasks.

OpenDSP in action
-----------------

[Emulating a classic Dub Sound System setup for DJing](https://www.youtube.com/watch?v=2uJZTJCUkSI): a mixer, 2 decks, spring reverb and tape delay. Just [map you midi controller](https://github.com/midilab/opendsp-mods/blob/master/midilab/mixxx-dub/README.md) and plug it to your OpenDSP.

OpenDSP Interface
-----------------

OpenDSP provides a primary system interface that can be accessed through MIDI or OSC protocols.

Moreover, when you connect OpenDSP to your network, you gain access to additional interfaces such as:

**Network Share:** All user data including samplers, DJ set music files, and system configurations can be accessed from Linux, Mac, or Windows without requiring any prior configuration. Simply search for the network share named “opendsp.”

**Virtual Screen:** Depending on the opendsp app ecosystem, certain programs may require X11 support. In such cases, you have the option to interact with a web browser interface. Access it through this address: [http://opendsp/](http://opendsp/). Alternatively, for a more stable connection, you can use direct VNC access at “opendsp:5900.”

[![](https://midilab.co/data/uploads/2019/01/plugmod-opendsp.jpg)](https://midilab.co/data/uploads/2019/01/plugmod-opendsp.jpg)

**Plug-and-Play WiFi Dongle:** OpenDSP features built-in plug-and-play support for WiFi dongles. It automatically creates an access point named “OpenDSP,” allowing you to interface with your opendsp via WiFi using your mobile phone or tablet. The default password is “opendspd.”

Please note that the main video output, typically accessed through HDMI or DVI ports, is dedicated to video projection. Therefore, it is recommended not to use this display for app management purposes. Instead, utilize the Virtual Display.

OpenDSP Applications
--------------------

OpenDSP application is a subset of numerous applications, collectively referred to as “Mod”, which have predefined state relations between them.

A Mod can consist of any number of applications and establish audio/video connections between them, limited only by the processing capacity of your system.

By combining different applications, you can accomplish various types of DSP tasks, creating standalone dedicated audio/video devices that can be controlled using MIDI and OSC protocols or managed through a conventional mouse, keyboard, and monitor desktop station.

Creating your own Mod requires only a few lines of configuration. You can find helpful examples in the mod/ directory of the user data partition.

System Applications
-------------------

You can create Mods using the following open-source apps:  
**loopers:** giada, luppp  
**djing:** mixxx, wxax  
**daw/sequencer:** lmms, hydrogen, qtractor, non-daw, non-mixer, non-sequencer  
**trackers:** sunvox, milkytrack, klystrac  
**modular synthesis:** carla, carla-rack, ingen  
**video:** lebiniou, omxplayer, vlc  
**DSP programming:** puredata, processing  
**plugins:** 410+ audio plugins, from effects to classic synthesizer emulations

By utilizing Mod configuration files, you have the flexibility to define your own setups with just a few lines of configuration.  
  
In the example you mentioned, you can configure a standalone tracker that visually responds to audio on your screen. Additionally, you can set up a keyboard as a MIDI controller to play SunVox synthesizers.   

```ini
[app1]
name: sunvox-lofi
path: /projects/sunvox/
project: Transient - Can It Be Beautiful.sunvox
display: virtual
midi_input: "opendsp:1"
audio_output: "opendsp:1, opendsp:2"

[app2]
name: lebiniou
path: /projects/lebiniou/
args: -x 640 -y 480
display: native
audio_input: "sunvox:1, sunvox:2"

[app3]
name: input2midi
path: /projects/input2midi/
project: inputtomidi.json
midi_output: "opendsp:1"
```

User manual
-----------

You can get the latest documentation on our [wiki](https://github.com/midilab/opendsp/wiki)  

# Initing dependency repositories

git submodule update --init --recursive

# Build

The best way to build opendsp is using docker and official supported yocto image for dev crops

docker run --rm -it -v /path_to_/opendsp:/workdir crops/poky --workdir=/workdir

TEMPLATECONF=/workdir/meta-opendsp/conf source poky/oe-init-build-env
bitbake opendsp-base-image

# Depends

openembedded-core
meta-openembedded:
  + meta-oe
  + meta-python
  + meta-multimedia
  + meta-networking
