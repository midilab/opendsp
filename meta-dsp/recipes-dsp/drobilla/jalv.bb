SUMMARY = "Jalv is a simple but fully featured LV2 host for Jack"
HOMEPAGE = "http://drobilla.net/software/jalv"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://COPYING;md5=f6c5b43b95e2c2f1a006d1310332a8fb"

inherit waf pkgconfig gtk-icon-cache

DEPENDS += " \
    qtbase-native \
    lv2 \
    lilv \
    serd \
    sord \
    sratom \
    suil \
    jack \
    gtkmm \
    gtk+3 \
    qtbase \
"

SRC_URI = " \
    gitsm://gitlab.com/drobilla/jalv.git;protocol=https;branch=main \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRCREV = "9ab6e66c6ea7230f716b74d62c03fc5d19f56abe"
S = "${WORKDIR}/git"
PV = "1.6.6"

FILES:${PN} += " \
    ${libdir}/jack \
"
