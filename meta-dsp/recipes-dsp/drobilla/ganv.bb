SUMMARY = "Ganv is a Gtk widget for interactive graph-like environments"
DESCRIPTION = "Ganv is a Gtk widget for interactive graph-like environments, such as modular synthesizers or finite state machines"
HOMEPAGE = "http://drobilla.net/software/ganv"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit waf pkgconfig

DEPENDS += " \
    glib-2.0-native \
    gtk+ \
    gtkmm \
"

SRC_URI = " \
    gitsm://gitlab.com/drobilla/ganv.git;protocol=https;branch=main \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRCREV = "17f58b94abf5e7b1ad7ea3c40d0cd1107298d41a"
S = "${WORKDIR}/git"
PV = "1.8.0"
