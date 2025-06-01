SUMMARY = "Lightweight C library of portability wrappers and data structures"
HOMEPAGE = "http://drobilla.net/software/zix"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=c17d0f531d833bea1a6c6823ba18c242"

inherit meson pkgconfig

SRC_URI = " \
    gitsm://gitlab.com/drobilla/zix.git;protocol=https;branch=main \
"
# 0.6.2
SRCREV = "ee35824ffe3eaf5d1cc32ceca3233b723aac7d43"

S = "${WORKDIR}/git"
