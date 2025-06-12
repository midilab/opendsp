SUMMARY = "Potluck with different functions for different purposes that can be shared among C programs"
DESCRIPTION = "Orcania is a C library providing various utility functions for C programs."
HOMEPAGE = "https://github.com/babelouest/orcania"
LICENSE = "LGPL-2.1-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=fc178bcd425090939a8b634d1d6a9594"

SRC_URI = "git://github.com/babelouest/orcania.git;branch=master;protocol=https"
SRCREV = "ffc8b55d09a3488f4f6be38034b33bc64bf8b0ce"

S = "${WORKDIR}/git"

PV = "2.3.3"

inherit cmake pkgconfig

EXTRA_OECMAKE = "\
    -DBUILD_STATIC=OFF \
    -DWITH_STRSTR=OFF \
    -DBUILD_ORCANIA_TESTING=OFF \
    -DINSTALL_HEADER=ON \
    -DBUILD_ORCANIA_DOCUMENTATION=OFF \
    -DCMAKE_BUILD_TYPE=Release \
"

# Optionally, if you want to build static library as well, set -DBUILD_STATIC=ON

do_install:append() {
    # Orcania installs to /usr/local by default, but Yocto handles DESTDIR
    # If any additional install steps are needed, add them here
    :
}
