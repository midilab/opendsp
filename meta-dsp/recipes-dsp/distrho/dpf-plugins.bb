SUMMARY = "Collection of DPF-based plugins"
LICENSE = "ISC & GPL-2.0-only & GPL-3.0-only & LGPL-3.0-only & MIT"
LIC_FILES_CHKSUM = " \
    file://LICENSE;md5=ec024abddfab2ee463c8c1ad98883d12 \
"

SRC_URI = "git://github.com/DISTRHO/DPF-Plugins.git;branch=main;protocol=https"
SRCREV = "0e6116c77e7d341306cdf8db827c2c2c3ec031d9"
S = "${WORKDIR}/git"
PV = "v1.7"

REQUIRED_DISTRO_FEATURES = "x11 opengl"

inherit pkgconfig pack_audio_plugins features_check

# TODO standalone: *.desktop
DEPENDS += " \
    lv2-ttl-generator-native \
    virtual/libgl \
    cairo \
    lv2 \
    liblo \
    jack \
    projectm \
"

EXTRA_OEMAKE += " \
    NOOPT=true \
    SKIP_STRIPPING=true \
"

export LV2_TTL_GENARATOR = "${STAGING_DIR_NATIVE}${bindir_native}/lv2-ttl-generator"

do_configure:append() {
    # create symbolic link for LV2_TTL_GENARATOR at ${S}/dpf/utils/lv2_ttl_generator
    ln -sf "${LV2_TTL_GENARATOR}" "${S}/dpf/utils/lv2_ttl_generator"
}

do_compile:prepend() {
    # projectm fails to find sysroot /usr/lib where libprojectm.so.0 lives
    export LD_LIBRARY_PATH="${STAGING_DIR_TARGET}/usr/lib:${LD_LIBRARY_PATH}"
}

do_install() {
    install -d ${D}${bindir}
    for executable in `find ${S}/bin/ -executable -mindepth 1 -maxdepth 1 -type f ! -name '*.so'`; do
        install -m 755 $executable ${D}${bindir}
    done

    #install -d ${D}${libdir}/ladspa
    #for plugin in `find ${S}/bin/ -name *ladspa.so`; do
    #    install -m 644 $plugin ${D}${libdir}/ladspa/
    #done

    install -d ${D}${libdir}/lv2
    for plugindir in `find ${S}/bin/ -maxdepth 1 -name *.lv2`; do
        lv2dir=${D}${libdir}/lv2/`basename $plugindir`
        install -d $lv2dir
        for plugin in `find $plugindir -type f`; do
            install -m 644 $plugin $lv2dir/
        done
    done

    install -d ${D}${libdir}/vst
    for plugin in `find ${S}/bin/ -name *vst.so`; do
        install -m 644 $plugin ${D}${libdir}/vst/
    done
}

PACKAGES =+ "${PN}-standalone"
FILES:${PN}-standalone = "${bindir}"
