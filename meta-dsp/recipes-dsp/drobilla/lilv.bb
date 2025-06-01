SUMMARY = "C library providing simple use of LV2 plugins"
HOMEPAGE = "http://drobilla.net/software/lilv"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=7e70199cf220ed471b0bf4ccdd02261e"

inherit meson python3native bash-completion pkgconfig

DEPENDS += "lv2 serd sord sratom"

PV = "0.24.26"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.xz \
"
SRC_URI[sha256sum] = "22feed30bc0f952384a25c2f6f4b04e6d43836408798ed65a8a934c055d5d8ac"

# Python bindings package definition remains the same
PACKAGES += "${PN}-python3"
FILES:${PN}-python3 += "${PYTHON_SITEPACKAGES_DIR}"
RDEPENDS:${PN}-python3 += "python3-core"
