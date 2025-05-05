SUMMARY = "projectM is a MilkDrop compatible opensource music visualizer"
HOMEPAGE = "http://projectm-visualizer.github.io/projectm"
LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://LICENSE.txt;md5=26f590fe167311fe2a5a7ce0b3e71900"

inherit autotools-brokensep pkgconfig features_check
inherit ${@bb.utils.contains('PACKAGECONFIG', 'qt', 'qmake5_paths', '', d)}

REQUIRED_DISTRO_FEATURES = "opengl ${@bb.utils.contains('PACKAGECONFIG', 'qt', 'pulseaudio', '', d)}"

DEPENDS += " \
    libglu \
    glew \
"

SRC_URI = " \
    git://github.com/projectM-visualizer/projectm.git;name=projectm;branch=master;protocol=https \
	http://spiegelmc.com.s3.amazonaws.com/pub/projectm_presets.zip;name=presets \
    file://0001-find-native-qt-build-tools-by-configure-options-auto.patch \
    file://0002-Makefile.am-Fix-installation-with-DESTDIR-set.patch \
"
SRCREV_projectm = "595bb28b6c3fbb104a4af21607b20c176b283b89"
SRC_URI[presets.md5sum] = "8976d72c05e3f4ddee996c6f2e98fc63"
SRC_URI[presets.sha256sum] = "e323515f0ee5920ec45e4f9efdb55890f028dabb5ae9468fdc97c43d55040614"

S = "${WORKDIR}/git"
PV = "2.2.1+git${SRCPV}"

# Many options are Qt related but can be set unconditionally
EXTRA_OECONF += " \
    --with-moc=${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}/moc \
    --with-uic=${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}/uic \
    --with-rcc=${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}/rcc \
"

PACKAGECONFIG ??= "ftgl sdl2"
PACKAGECONFIG[ftgl] = "--enable-ftgl,--disable-ftgl,ftgl"
PACKAGECONFIG[sdl2] = "--enable-sdl,--disable-sdl,libsdl2"

# Note: qtbase must be configured with desktop gl / gles won't work
PACKAGECONFIG[qt] = "--enable-qt,--disable-qt,qtbase-native qtbase pulseaudio"

do_install:append() {
    # Install presets manually for now
    install -m 0644 ${S}/presets/presets_projectM/* ${D}/${datadir}/projectM/presets/

    # Remove native presets for now - they are at the wrong location
    rm -f ${D}/${datadir}/projectM/presets/*.a
    rm -f ${D}/${datadir}/projectM/presets/*.so*
}

FILES:${PN} += " \
    ${datadir}/projectM \
"
