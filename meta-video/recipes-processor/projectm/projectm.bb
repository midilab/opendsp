SUMMARY = "projectM is a MilkDrop compatible opensource music visualizer"
HOMEPAGE = "http://projectm-visualizer.github.io/projectm"
LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=26f590fe167311fe2a5a7ce0b3e71900"

inherit autotools-brokensep pkgconfig qmake5_base features_check
inherit ${@bb.utils.contains('PACKAGECONFIG', 'qt', 'qmake5_paths', '', d)}

REQUIRED_DISTRO_FEATURES = "opengl ${@bb.utils.contains('PACKAGECONFIG', 'qt', 'x11', '', d)}"

DEPENDS += " \
    qtbase-native \
    qtbase \
    jack \
    libglu \
    glew \
    glm \
"

SRC_URI = "git://github.com/projectM-visualizer/projectm.git;name=projectm;branch=master;protocol=https"
SRCREV_projectm = "f8d16844613de4a6a8ce9d01f1efa9bae2dbdedc"

S = "${WORKDIR}/git"
PV = "3.1.7+git${SRCPV}"

EXTRA_OECONF += " \
    --enable-jack \
"

# for embedded systems...
#--enable--gles

do_configure:append() {
    # Patch Makefile.in to use the full path for PRESETSDIR
    sed -i 's|PRESETSDIR = presets|PRESETSDIR = ${S}/presets|' ${S}/Makefile.in
}

do_install:append() {
    # Install presets manually for now
    # avaliable:
    # presets_bltc201, presets_milkdrop_104, presets_projectM, presets_yin, presets_eyetune, presets_milkdrop_200, presets_stock, presets_milkdrop, presets_mischa_collection, presets_tryptonaut
    install -m 0644 ${S}/presets/presets_projectM/* ${D}/${datadir}/projectM/presets/

    # Remove native presets for now - they are at the wrong location
    rm -f ${D}/${datadir}/projectM/presets/*.so*
}

FILES:${PN} += " \
    ${datadir}/projectM/ \
    ${datadir}/icons/ \
"
