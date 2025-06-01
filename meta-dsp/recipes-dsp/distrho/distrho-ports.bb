SUMMARY = "Collection of synthesizers and plugins"
HOMEPAGE = "http://distrho.sourceforge.net/ports"
LICENSE = "GPL-2.0-only & LGPL-3.0-only"
LIC_FILES_CHKSUM = " \
    file://doc/GPL.txt;md5=4641e94ec96f98fabc56ff9cc48be14b \
    file://doc/LGPL.txt;md5=e6a600fd5e1d9cbde2d983680233ad02 \
"

SRC_URI = " \
    git://github.com/DISTRHO/DISTRHO-Ports.git;branch=master;protocol=https \
    \
    http://linuxsynths.com/ObxdPatchesDemos/ObxdPatchesBrian-01.tar.gz;name=linuxsynths-obxd-patches1;subdir=linuxsynths-obxd-patches \
    \
    http://linuxsynths.com/VexPatchesDemos/VexPatches01.tar.gz;name=linuxsynths-vex-patches1;subdir=linuxsynths-vex-patches \
    http://linuxsynths.com/VexPatchesDemos/VexPatches02.tar.gz;name=linuxsynths-vex-patches2;subdir=linuxsynths-vex-patches \
"

SRCREV = "2131ac41eef308c2ba11df6f1ae3985f3c868485"
S = "${WORKDIR}/git"
PV = "2021-03-15+git${SRCPV}"

SRC_URI[linuxsynths-obxd-patches1.md5sum] = "32244f847a54a71ee3c25079df5c8b84"
SRC_URI[linuxsynths-obxd-patches1.sha256sum] = "246fccadd71bb9f0606a95bf7b0aee7807fd3a14f754367425423a51c31e160e"

SRC_URI[linuxsynths-vex-patches1.md5sum] = "c03f8ac9eaf3fabb3c98af5cb27a5edb"
SRC_URI[linuxsynths-vex-patches1.sha256sum] = "1a32ba4ba52d0efcd2214e52ecf9ea71885d110261c2b26e23ccdbd0960b6f60"
SRC_URI[linuxsynths-vex-patches2.md5sum] = "a3d00bf9eb7e2381ffc56f3e79e067ec"
SRC_URI[linuxsynths-vex-patches2.sha256sum] = "378cff261dab333c5f29246b6f3f557e0461e8bc230519da3a1a9049cbd437d5"

REQUIRED_DISTRO_FEATURES = "x11 opengl"

inherit meson pkgconfig features_check pack_audio_plugins

DEPENDS += " \
    lv2-native \
    lv2-ttl-generator-native \
    alsa-lib-native \
    virtual/libgl \
    alsa-lib \
    libx11 \
    libxext \
    libxcursor \
    freetype \
    fftw \
"

export LV2_TTL_GENARATOR = "${STAGING_DIR_NATIVE}${bindir_native}/lv2-ttl-generator"

EXTRA_OEMESON += " \
    -Dplugins='arctican-function,arctican-pilgrim,dexed,drowaudio-distortion,drowaudio-distortionshaper,drowaudio-flanger,drowaudio-reverb,drowaudio-tremolo,drumsynth,easySSP,eqinox,HiReSam,juce-opl,klangfalter,LUFSMeter,LUFSMeter-Multi,luftikus,obxd,pitchedDelay,refine,stereosourceseparation,tal-dub-3,tal-filter,tal-filter-2,tal-noisemaker,tal-reverb,tal-reverb-2,tal-reverb-3,tal-vocoder-2,temper,vex,wolpertinger,vitalium' \
    -Dbuild-lv2=true \
    -Dbuild-vst2=false \
    -Dbuild-vst3=true \
"

do_configure:append() {
    # meson thinks it is cross-compile(wich it is, but no wine needed, lets rely on lv2-ttl-generator-native)
    sed -i "s#(meson.is_cross_build() ? 'wine' : 'env'), lv2_ttl_generator#'env', 'LD_LIBRARY_PATH=${STAGING_DIR_NATIVE}${libdir_native}', '${LV2_TTL_GENARATOR}'#g" ${S}/ports/meson.build
    sed -i "s#(meson.is_cross_build() ? 'wine' : 'env'), lv2_ttl_generator#'env', 'LD_LIBRARY_PATH=${STAGING_DIR_NATIVE}${libdir_native}', '${LV2_TTL_GENARATOR}'#g" ${S}/ports-legacy/meson.build
}

do_install:append() {
    # obxd-presets
    for file in `find ${WORKDIR}/linuxsynths-obxd-patches -mindepth 1 -maxdepth 1` ; do
        cp -rf $file ${D}${libdir}/lv2/
    done
    # vex-presets
    for file in `find ${WORKDIR}/linuxsynths-vex-patches -mindepth 1 -maxdepth 1` ; do
        cp -rf $file ${D}${libdir}/lv2/
    done
}

PACKAGES =+ "${PN}-presets"
RDEPENDS:${PN}-presets = "${PN_LV2}"

FILES:${PN}-presets = " \
    ${libdir}/lv2/*.preset.lv2 \
    ${libdir}/lv2/*/presets.ttl \
    ${libdir}/lv2/Vitalium-unfa.lv2 \
"

# Have not found what causes stripping - debugging of plugins is unlikely
INSANE_SKIP:${PN} = "already-stripped"
