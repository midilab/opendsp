SUMMARY = "C library for storing RDF data in memory"
HOMEPAGE = "http://drobilla.net/software/sord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=7e70199cf220ed471b0bf4ccdd02261e"

inherit meson pkgconfig

DEPENDS += "libpcre serd zix"

PV = "0.16.18"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.xz \
"
SRC_URI[sha256sum] = "4f398b635894491a4774b1498959805a08e11734c324f13d572dea695b13d3b3"
