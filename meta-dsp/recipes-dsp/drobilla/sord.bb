SUMMARY = "C library for storing RDF data in memory"
HOMEPAGE = "http://drobilla.net/software/sord"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=b698a6a2120a83eecb34a9c6f1b93989"

inherit waf pkgconfig

DEPENDS += "libpcre serd"

PV = "0.16.10"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.bz2 \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRC_URI[sha256sum] = "9c70b3fbbb0c5c7bf761ef66c3d5b939ab45ad063e055990f17f40f1f6f96572"
