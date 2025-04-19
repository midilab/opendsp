SUMMARY = "MDA-LV2 is an LV2 port of the MDA plugins by Paul Kellett"
HOMEPAGE = "https://drobilla.net/software/mda-lv2"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit waf features_check pkgconfig

REQUIRED_DISTRO_FEATURES = "x11"

DEPENDS = "lv2"

SRC_URI = " \
    gitsm://gitlab.com/drobilla/mda-lv2.git;protocol=https;branch=main \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRCREV = "19752af61234581e0f73db539d5609ab14b3d928"
PV = "1.2.6"
S = "${WORKDIR}/git"

EXTRA_OECONF = " \
    --lv2dir=${libdir}/lv2 \
"

FILES:${PN} += "${libdir}/lv2"
