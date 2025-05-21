SUMMARY = "Audio plugin host"
HOMEPAGE = "http://kxstudio.linuxaudio.org/Applications:Carla"
LICENSE = "GPL-2.0-only & LGPL-3.0-only"
LIC_FILES_CHKSUM = " \
    file://doc/GPL.txt;md5=4641e94ec96f98fabc56ff9cc48be14b \
    file://doc/LGPL.txt;md5=e6a600fd5e1d9cbde2d983680233ad02 \
"

SRC_URI = " \
    git://github.com/falkTX/Carla.git;branch=main;protocol=https \
    file://0001-do-not-try-to-cross-run-carla-lv2-export.patch \
"
SRCREV = "6bc9a90ebb1767649d2538108ed4a604ce96dacb"
# latest before qt6 update
# c37d53a4216654118e711fa41e88e7e801d5bd9b
S = "${WORKDIR}/git"
PV = "2.5.0"

REQUIRED_DISTRO_FEATURES = "x11"

inherit qmake5_base python3native pkgconfig qemu-ext-musicians features_check mime mime-xdg gtk-icon-cache

B = "${S}"

DEPENDS += " \
    python3-pyqt5-native \
    qtbase-native \
    qtbase \
    gtk+ \
    gtk+3 \
    liblo \
    pulseaudio \
    fluidsynth \
    libsndfile1 \
"

EXTRA_OEMAKE += " \
    DEFAULT_QT=5 \
    NOOPT=true \
    HAVE_PYQT=true \
    HAVE_PYQT4=false \
    HAVE_PYQT5=true \
    SKIP_STRIPPING=true \
"

export QT5_HOSTBINS="${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}"

do_configure() {
    # Fix the python3.10 path in pyrcc5 and pyuic5
    sed -i 's|/workdir/build/tmp/work/x86_64-linux/python3-pyqt5-native/5.15.7-r0/image//workdir/build/tmp/work/corei7-64-midilab-linux/carla/2.5.0-r0/recipe-sysroot-native/usr/bin/python3.10|/workdir/build/tmp/work/corei7-64-midilab-linux/carla/2.5.0-r0/recipe-sysroot-native/usr/bin/python3-native/python3.10|g' ${STAGING_DIR_NATIVE}/usr/bin/pyrcc5
    sed -i 's|/workdir/build/tmp/work/x86_64-linux/python3-pyqt5-native/5.15.7-r0/image//workdir/build/tmp/work/corei7-64-midilab-linux/carla/2.5.0-r0/recipe-sysroot-native/usr/bin/python3.10|/workdir/build/tmp/work/corei7-64-midilab-linux/carla/2.5.0-r0/recipe-sysroot-native/usr/bin/python3-native/python3.10|g' ${STAGING_DIR_NATIVE}/usr/bin/pyuic5

    oe_runmake features
}

do_compile:append() {
    cd ${S}/bin
    ${@qemu_run_binary_local(d, '${STAGING_DIR_TARGET}', 'carla-lv2-export')}
    cd ${S}/bin/carla.lv2 && ln -sf ../*bridge-* ../carla-discovery-* .
}

do_install() {
    oe_runmake DESTDIR=${D} PREFIX=${prefix} LIBDIR=${libdir} install
}

FILES:${PN} += " \
    ${datadir}/appdata \
    ${datadir}/icons \
    ${datadir}/mime \
    ${libdir}/jack \
    ${libdir}/lv2 \
    ${libdir}/vst \
"

INSANE_SKIP:${PN} = "dev-so"

RDEPENDS:${PN} += "python3-pyqt5 bash"
