SUMMARY = "Suil is a lightweight C library for loading and wrapping LV2 plugin UIs"
HOMEPAGE = "https://drobilla.net/software/suil"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=323e8282a413e218c2ec674a44c02cf4"

inherit waf features_check pkgconfig

REQUIRED_DISTRO_FEATURES = "x11"

DEPENDS = "gtk+ gtk+3 qtbase lv2"

PV = "0.10.12"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.bz2 \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRC_URI[sha256sum] = "daa763b231b22a1f532530d3e04c1fae48d1e1e03785e23c9ac138f207b87ecd"

FILES:${PN} += "${libdir}/suil-0"
