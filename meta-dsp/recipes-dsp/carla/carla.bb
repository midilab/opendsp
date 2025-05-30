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
SRCREV = "17000e7fe99459b25a50094a8b00bdfa12f2bfbc"
S = "${WORKDIR}/git"
PV = "2.5.9"

REQUIRED_DISTRO_FEATURES += " x11"

inherit qmake5_base python3native pkgconfig qemu-ext-musicians features_check mime mime-xdg gtk-icon-cache

B = "${S}"

DEPENDS += " \
    python3-pyqt5-native \
    python3-pyqt5-sip-native \
    qtbase-native \
    qtbase \
    gtk+ \
    gtk+3 \
    liblo \
    fluidsynth \
    libsndfile1 \
"

EXTRA_OEMAKE += " \
    SKIP_STRIPPING=true \
"

export QT5_HOSTBINS="${OE_QMAKE_PATH_EXTERNAL_HOST_BINS}"
export UIC_QT5="${STAGING_DIR_NATIVE}/usr/bin/uic"
export MOC_QT5="${STAGING_DIR_NATIVE}/usr/bin/moc"
export RCC_QT5="${STAGING_DIR_NATIVE}/usr/bin/rcc"

do_configure() {
    # Fix the python3 path in pyrcc5 and pyuic5
    sed -i 's|/usr/bin/python3 |/usr/bin/python3-native/python3 |g' ${STAGING_DIR_NATIVE}/usr/bin/pyrcc5
    sed -i 's|/usr/bin/python3 |/usr/bin/python3-native/python3 |g' ${STAGING_DIR_NATIVE}/usr/bin/pyuic5

    oe_runmake features
}

do_compile:append() {
    cd ${S}/bin
    ${@qemu_run_binary_local(d, '${STAGING_DIR_TARGET}', 'carla-lv2-export')}
    cd ${S}/bin/carla.lv2 && ln -sf ../*bridge-* ../carla-discovery-* .
}

do_install() {
    oe_runmake DESTDIR=${D} PREFIX=${prefix} LIBDIR=${libdir} install

    # Create skel directory structure and symbolic link for runtime user data
    install -d ${D}${sysconfdir}/skel/data/app/falkTX
    install -d ${D}${sysconfdir}/skel/.config
    ln -sf ../data/app/falkTX ${D}${sysconfdir}/skel/.config/falkTX

    # Remove redundant RPATH
    chrpath --delete ${D}${libdir}/carla/styles/carlastyle.so || true
}

FILES:${PN} += " \
    ${datadir}/appdata \
    ${datadir}/icons \
    ${datadir}/mime \
    ${libdir}/jack \
    ${libdir}/lv2 \
    ${libdir}/vst \
    ${sysconfdir}/skel \
"

INSANE_SKIP:${PN} = "dev-so"

RDEPENDS:${PN} += "python3-pyqt5 bash"
