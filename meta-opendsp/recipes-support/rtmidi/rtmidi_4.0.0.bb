SUMMARY = "Real-time Midi I/O C++ Library"
HOMEPAGE = "http://www.music.mcgill.ca/~gary/rtmidi/index.html"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://README.md;beginline=39;endline=66;md5=1fe9a84d1f8505107a519996977deba8"

inherit cmake pkgconfig

PACKAGECONFIG ??= "alsa jack"
PACKAGECONFIG[alsa] = "-DRTMIDI_API_ALSA=ON,-DRTMIDI_API_ALSA=OFF,alsa-lib"
PACKAGECONFIG[jack] = "-DRTMIDI_API_JACK=ON,-DRTMIDI_API_JACK=OFF,jack"

SRC_URI = " \
    https://www.music.mcgill.ca/~gary/${BPN}/release/${BPN}-${PV}.tar.gz \
    file://0001-Fix-cmake-file-installation-path.patch \
    file://0002-Avoid-links-to-build-tmp-path.patch \
"
SRC_URI[sha256sum] = "370cfe710f43fbeba8d2b8c8bc310f314338c519c2cf2865e2d2737b251526cd"
