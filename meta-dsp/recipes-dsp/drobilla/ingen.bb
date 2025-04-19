SUMMARY = "Ingen is a modular audio processing system for Jack and LV2 based systems"
HOMEPAGE = "http://drobilla.net/software/ingen"
LICENSE = "AGPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=73f1eb20517c55bf9493b7dd6e480788"

inherit waf pkgconfig gtk-icon-cache pack_audio_plugins python3native

DEPENDS += " \
    boost \
    gtkmm \
    lilv \
    suil \
    raul \
    ganv \
    portaudio-v19 \
"

SRC_URI = " \
    gitsm://gitlab.com/drobilla/ingen.git;protocol=https;branch=main \
    file://0001-Fix-build-for-python3-only-environments.patch \
"
SRCREV = "36949a845cf79e105445b9bc8656f2560469dc4d"
S = "${WORKDIR}/git"
PV = "0.5.1+git${SRCPV}"

DOCDEPENDS = " \
    lv2-native \
    doxygen-native \
    graphviz-native \
    gdk-pixbuf-native \
    libpng-native \
    python-rdflib-native \
    python-isodate-native \
    python-six-native \
"
PACKAGECONFIG[doc] = "--docs,,${DOCDEPENDS}"

PACKAGES =+ "${PN}-standalone ${PN}-python"

FILES_SOLIBSDEV = "${libdir}/libingen-*${SOLIBSDEV}"

FILES:${PN} += " \
    ${libdir}/libingen_*.so \
"

FILES:${PN}-standalone = " \
    ${datadir}/applications \
    ${datadir}/icons \
    ${bindir}/ingen \
"

# pyton tools are not expected to work: we do not have rdflib yet
FILES:${PN}-python = " \
    ${bindir}/ingenams \
    ${bindir}/ingenish \
    ${PYTHON_SITEPACKAGES_DIR} \
"
