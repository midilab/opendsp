SUMMARY = "C library for RDF syntax which supports accessing Turtle and NTriples"
HOMEPAGE = "http://drobilla.net/software/serd"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=558bb64a60a6e1db7037ca99f435ec2e"

inherit meson pkgconfig

PV = "0.32.4"
SRC_URI = " \
    http://download.drobilla.net/${BPN}-${PV}.tar.xz \
"
SRC_URI[sha256sum] = "cbefb569e8db686be8c69cb3866a9538c7cb055e8f24217dd6a4471effa7d349"
