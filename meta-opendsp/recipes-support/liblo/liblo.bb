SUMMARY = "liblo is an implementation of the Open Sound Control protocol"
HOMEPAGE = "http://liblo.sourceforge.net"
LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=fbc093901857fcd118f065f900982c24"

inherit autotools pkgconfig

SRC_URI = "${SOURCEFORGE_MIRROR}/project/${BPN}/${BPN}/${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[md5sum] = "a93a7a9da084e6a0937bde6fc324a52a"
PV = "0.32"
