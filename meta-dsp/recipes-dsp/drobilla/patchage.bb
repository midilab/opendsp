SUMMARY = "Patchage is a modular patch bay for audio and MIDI systems"
DESCRIPTION = "Patchage is a modular patch bay for audio and MIDI systems based on Jack and Alsa"
HOMEPAGE = "http://drobilla.net/software/patchage"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit waf gtk-icon-cache pkgconfig

DEPENDS += " \
    boost \
    jack \
    ganv \
"

SRC_URI = " \
    gitsm://gitlab.com/drobilla/patchage.git;protocol=https;branch=main \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRCREV = "1eed3df05526b22d716a2f89f166804f894ac5b1"
PV = "1.0.6"
S = "${WORKDIR}/git"
