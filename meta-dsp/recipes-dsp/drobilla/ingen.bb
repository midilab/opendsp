SUMMARY = "Ingen is a modular audio processing system for Jack and LV2 based systems"
HOMEPAGE = "http://drobilla.net/software/ingen"
LICENSE = "AGPL-3.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=73f1eb20517c55bf9493b7dd6e480788"

# Use meson instead of waf
inherit meson pkgconfig gtk-icon-cache pack_audio_plugins python3native

DEPENDS += " \
    boost \
    gtkmm \
    lilv \
    suil \
    raul \
    ganv \
    portaudio-v19 \
"

# Runtime dependency for python tools (add more if needed, e.g., python3-rdflib)
# RDEPENDS:${PN}-python += "python3 python3-rdflib"

SRC_URI = " \
    gitsm://gitlab.com/drobilla/ingen.git;protocol=https;branch=main \
"
SRCREV = "13a045d01c7a77fc918b7f496f5bf96ade4f6812"

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
# Use meson feature option for docs
PACKAGECONFIG[doc] = "-Ddocs=enabled,-Ddocs=disabled,${DOCDEPENDS}"

PACKAGES =+ "${PN}-standalone ${PN}-python"

# Adjust library name if Meson installs it differently (e.g., libingen-0.so)
# Check the actual library name in ${D}${libdir} after compilation.
FILES_SOLIBSDEV = "${libdir}/libingen${SOLIBSDEV}"

# Main package: runtime library. LV2 plugins handled by pack_audio_plugins class.
# Ensure the library pattern matches the actual installed library.
FILES:${PN} += " \
    ${libdir}/libingen-0.so.* \
    ${libdir}/libingen_jack.so \
    ${libdir}/libingen_server.so \
    ${libdir}/libingen_client.so \
    ${libdir}/libingen_gui.so \
    ${libdir}/libingen_portaudio.so \
"
# Note: Removed explicit ${libdir}/lv2 - let pack_audio_plugins handle it.

FILES:${PN}-dev += "${libdir}/libingen-0.so"

FILES:${PN}-standalone = " \
    ${datadir}/applications \
    ${datadir}/icons \
    ${bindir}/ingen \
"

# Python tools and any installed modules
# Note: The comment about rdflib still applies; functionality might depend on runtime deps.
FILES:${PN}-python = " \
    ${bindir}/ingenams \
    ${bindir}/ingenish \
    ${PYTHON_SITEPACKAGES_DIR} \
"
