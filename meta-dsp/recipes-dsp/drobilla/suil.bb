SUMMARY = "Suil is a lightweight C library for loading and wrapping LV2 plugin UIs"
HOMEPAGE = "https://drobilla.net/software/suil"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=b5f0db0454006d99276ee4a1e4cf17e4"

inherit meson features_check pkgconfig

REQUIRED_DISTRO_FEATURES = "x11"

DEPENDS = "gtk+ gtk+3 qtbase lv2"

PV = "0.10.22"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.xz \
"
SRC_URI[sha256sum] = "d720969e0f44a99d5fba35c733a43ed63a16b0dab867970777efca4b25387eb7"

FILES:${PN} += "${libdir}/suil-0"
