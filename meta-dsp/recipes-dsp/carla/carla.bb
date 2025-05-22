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

REQUIRED_DISTRO_FEATURES = "x11"

inherit pkgconfig qemu-ext-musicians features_check

B = "${S}"

EXTRA_OEMAKE += "SKIP_STRIPPING=true"

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

RDEPENDS:${PN} += "python3-pyqt5 qtbase bash"
