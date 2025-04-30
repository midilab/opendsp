SUMMARY = "Lightweight C library of portability wrappers and data structures"
HOMEPAGE = "http://drobilla.net/software/zix"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=c17d0f531d833bea1a6c6823ba18c242"

inherit meson pkgconfig

SRC_URI = " \
    gitsm://gitlab.com/drobilla/zix.git;protocol=https;branch=main \
"
SRCREV = "8b9a97eff86a6f9e0c3b21e329e34d6a4ff2ffa7"

S = "${WORKDIR}/git"
