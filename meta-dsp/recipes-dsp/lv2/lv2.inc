SUMMARY = "LV2 is an open standard for audio plugins"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://COPYING;md5=b1b33d6fcf7d70cf1512e3c481768a9c"

SRC_URI = " \
    gitsm://github.com/lv2/lv2.git;branch=main;protocol=https \
"
S = "${WORKDIR}/git"
SRCREV = "0bcde338db1c63bbc503b4d1f6d7b55ed43154af"
PV = "1.18.10"

inherit meson pkgconfig
