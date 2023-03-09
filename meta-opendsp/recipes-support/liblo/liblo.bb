SUMMARY = "liblo is an implementation of the Open Sound Control protocol"
HOMEPAGE = "http://liblo.sourceforge.net"
LICENSE = "LGPLv2.1"
LIC_FILES_CHKSUM = "file://COPYING;md5=fbc093901857fcd118f065f900982c24"

inherit autotools pkgconfig

SRC_URI = "${SOURCEFORGE_MIRROR}/project/${BPN}/${BPN}/${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[md5sum] = "14378c1e74c58e777fbb4fcf33ac5315"
SRC_URI[sha256sum] = "2b4f446e1220dcd624ecd8405248b08b7601e9a0d87a0b94730c2907dbccc750"
PV = "0.31"