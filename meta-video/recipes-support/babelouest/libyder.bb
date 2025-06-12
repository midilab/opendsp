SUMMARY = "Yder is a C library for logging messages, supporting multiple outputs and formats"
DESCRIPTION = "Yder provides a simple and flexible logging library for C programs, supporting multiple log levels, outputs, and formats."
HOMEPAGE = "https://github.com/babelouest/yder"
LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=40d2542b8c43a3ec2b7f5da31a697b88"

SRC_URI = "git://github.com/babelouest/yder.git;branch=master;protocol=https"
SRCREV = "dffe82c0483bb95d0d518ba1e36c568e63a24628"

S = "${WORKDIR}/git"

PV = "1.4.20"

inherit cmake pkgconfig

DEPENDS += " \
    systemd \
    liborcania \
"

EXTRA_OECMAKE = "\
    -DBUILD_STATIC=OFF \
    -DBUILD_YDER_TESTING=OFF \
    -DINSTALL_HEADER=ON \
    -DBUILD_YDER_DOCUMENTATION=OFF \
    -DCMAKE_BUILD_TYPE=Release \
"

do_install:append() {
    # Libyder installs to /usr/local by default, but Yocto handles DESTDIR
    # If any additional install steps are needed, add them here
    :
}
