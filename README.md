# OpenDSP

OpenDSP is a Realtime Operational System aimed for audio and video
Digital Signal Processing on embeded devices like raspberry or
headless personal computers.

OpenDSP Service is a Framework to create DSP gears that can
fully interface with any MIDI or OSC compilant device. The source code are in python and is avaliable at:  https://github.com/midilab/opendspd/

The OpenDSP OS and Service together gives you the power to emulate a lot of different expensive proprietary DSP machines or to create your self a new one for your needs.

Achieve professional realtime low-latency audio and video processing on low budget computers!

OpenDSP is Good for:
+ Musicians
+ DJs
+ Audio and Video Producers
+ Video Art Producers and Performers
+ Multimedia Interactive Instalations
+ Theatre Sound Technicians
+ DSP Students and Researches

You can, for example, emulate a legendary Akai MPC or a Yamaha DX7 synthesizer, you can use it as as DJ system with or without vinyl timecode support. You can use it as a effect box and emulate classics like Roland Space Echo delay machine. You can use it as a mixing platform with support to the most common daily audio engeneering tools like compressors, limiters, expanders, multiband equalizers and so on...  

The opensource community gives you a very huge number of different applications that  

# Pre release

This pre-release is fully functional and quite stable, the image avaliable on the link above:  
  
[**Download Raspberry PI2 and PI3 0.10**](https://github.com/midilab/opendsp/releases/download/v0.10.0/opendsp_0.10.0-raspberry_pi2_3.zip)
    
## OpenDSP Apps

OpenDSP application is a sub-set of N applications with a predefined state relation between then called Mod.
  
A Mod can have any number of applications and audio/video connections between then as far as you processor can handle it all.  
  
By merging different applications you can achieve different kinda of DSP tasks to use as a standalone dedicated audio/video gear in an automated way via MIDI and OSC protocols or via common mouse/keyboard and monitor desktop station.  
  
You can write your own Mod with a very few lines of configuration, just check some examples at mod/ directory of user data partition.  

Examples can be found inside data/ directory.  
  
## App main interface

By making use of Mod config files you can define your own with a few lines of configuration  
  
On the above example you setup a standalone tracker with visualization responds to audio on your screen and a keyboard used as a midi controller to play some sunvox synthesizers.    

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
project: "opendsp,opendsp2"
display: native
audio_input: "sunvox:1, sunvox:2"

[app3]
name: input2midi
path: /projects/input2midi/
project: inputtomidi.json
midi_output: "opendsp:1"
```

## Ecosystem DSP applications

You can create Mods ussing the following opensource applications ecosystem:

+ loopers  
– giada  
– luppp  
+ djing  
– mixxx  
– wxax  
+ daw/sequencer  
– lmms  
– hydrogen  
– qtractor  
– non-daw  
– non-mixer  
– non-sequencer  
+ trackers  
– sunvox  
– milkytrack  
+ modular synthesis  
– carla  
– carla-rack  
– ingen  
+ video  
– lebiniou  
– xjadeo  
– vlc  
+ modular programming  
– puredata  
– processing
+ audio plugins  
410 audio plugins, from effects to classic synthesizer emulations  
