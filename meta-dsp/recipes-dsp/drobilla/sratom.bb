SUMMARY = "Sratom is a library for serialising LV2 atoms to and from RDF"
HOMEPAGE = "http://drobilla.net/software/sratom"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=02c12fd13bfe8cd6878ad1ea35778acf"

inherit waf pkgconfig

DEPENDS += "lv2 serd sord"

PV = "0.6.10"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.bz2 \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRC_URI[sha256sum] = "e5951c0d7f0618672628295536a271d61c55ef0dab33ba9fc5767ed4db0a634d"
