SUMMARY = "Sratom is a library for serialising LV2 atoms to and from RDF"
HOMEPAGE = "http://drobilla.net/software/sratom"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=dc26a3cda1e0de005cfe653f22ca5bcf"

inherit meson pkgconfig

DEPENDS += "lv2 serd sord"

PV = "0.6.18"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.xz \
"
SRC_URI[sha256sum] = "4c6a6d9e0b4d6c01cc06a8849910feceb92e666cb38779c614dd2404a9931e92"
