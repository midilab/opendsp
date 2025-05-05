SUMMARY = "Collection of DPF-based plugins"
LICENSE = "ISC & GPL-2.0-only & GPL-3.0-only & LGPL-3.0-only & MIT"
LIC_FILES_CHKSUM = " \
    file://LICENSE;md5=ec024abddfab2ee463c8c1ad98883d12 \
"

SRC_URI = "git://github.com/DISTRHO/DPF-Plugins.git;branch=main;protocol=https"
SRCREV = "014db6d4ef170b44653b1eb668686b624e4ae3f8"
S = "${WORKDIR}/git"
PV = "v1.4"

REQUIRED_DISTRO_FEATURES = "x11 opengl"

inherit pkgconfig lv2-turtle-helper pack_audio_plugins features_check

# TODO standalone: *.desktop
DEPENDS += " \
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

do_ttl_sed() {
    sed -i 's|${EXE_WRAPPER} "${GEN}" "./\x24{FILE}"|echo "`realpath  "./$FILE"`" >> ${LV2_PLUGIN_INFO_FILE}|g' ${S}/dpf/utils/generate-ttl.sh
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
