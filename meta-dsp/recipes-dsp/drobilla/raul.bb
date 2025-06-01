SUMMARY = "Raul is a utility library primarily aimed at audio/musical applications"
DESCRIPTION = "Raul (Realtime Audio Utility Library) is a C++ utility library primarily aimed at audio/musical applications"
HOMEPAGE = "https://drobilla.net/software/raul"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464"

inherit meson pkgconfig

DEPENDS = "boost"

SRC_URI = " \
    gitsm://github.com/drobilla/raul.git;protocol=https;branch=main \
"
SRCREV = "edac768a4334cec6cc569773a89100e709cbebf5"
S = "${WORKDIR}/git"
PV = "2.0.0+git${SRCPV}"
