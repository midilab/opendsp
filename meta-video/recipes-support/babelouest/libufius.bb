SUMMARY = "Ulfius is a C library to build REST APIs and Websockets services"
DESCRIPTION = "Ulfius provides a framework for building REST APIs and Websockets services in C, with support for JSON, HTTPS, logging, and more."
HOMEPAGE = "https://github.com/babelouest/ulfius"
LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=40d2542b8c43a3ec2b7f5da31a697b88"

SRC_URI = "git://github.com/babelouest/ulfius.git;branch=master;protocol=https"
SRCREV = "a0603447d3ed63c0880db396b9c395fb4bf6b559"

S = "${WORKDIR}/git"

PV = "2.7.15"

DEPENDS = "libmicrohttpd jansson curl gnutls libgcrypt zlib libyder liborcania systemd"

inherit cmake pkgconfig

EXTRA_OECMAKE = "\
    -DWITH_JANSSON=ON \
    -DWITH_CURL=ON \
    -DWITH_GNUTLS=ON \
    -DWITH_WEBSOCKET=ON \
    -DWITH_JOURNALD=ON \
    -DWITH_YDER=ON \
    -DBUILD_UWSC=ON \
    -DBUILD_STATIC=OFF \
    -DBUILD_ULFIUS_TESTING=OFF \
    -DBUILD_ULFIUS_DOCUMENTATION=OFF \
    -DINSTALL_HEADER=ON \
    -DCMAKE_BUILD_TYPE=Release \
"

do_install:append() {
    # Ulfius installs to /usr/local by default, but Yocto handles DESTDIR
    # If any additional install steps are needed, add them here
    :
}

# Optionally, you can split uwsc into its own package if desired.
# PACKAGES += "${PN}-uwsc"
# FILES:${PN}-uwsc += "${bindir}/uwsc"
