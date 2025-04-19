SUMMARY = "Raul is a utility library primarily aimed at audio/musical applications"
DESCRIPTION = "Raul (Realtime Audio Utility Library) is a C++ utility library primarily aimed at audio/musical applications"
HOMEPAGE = "https://drobilla.net/software/raul"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit waf pkgconfig

SRC_URI = " \
    gitsm://github.com/drobilla/raul.git;protocol=https;branch=main \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRCREV = "e87bb398f025912fb989a09f1450b838b251aea1"
S = "${WORKDIR}/git"
PV = "1.0.0+git${SRCPV}"
