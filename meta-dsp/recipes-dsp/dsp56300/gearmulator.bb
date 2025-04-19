SUMMARY = "Gearmulator is a emulation of classic VA synths of the late 90s/2000s that are based on Motorola 56300 family DSPs"
HOMEPAGE = "https://dsp56300.wordpress.com/"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=97a733ff40c50b4bfc74471e1f6ca88b"

# Inherit cmake for build system, pkgconfig for dependency detection,
# and pack_audio_plugins to handle LV2 packaging.
inherit cmake pkgconfig pack_audio_plugins features_check

REQUIRED_DISTRO_FEATURES = "x11"

# Add dependencies:
# - JUCE requires X11 libs, ALSA, FreeType, Fontconfig
# - Building LV2 plugins requires lv2 headers/libs
DEPENDS += " \
    libx11 \
    libxrandr \
    libxext \
    libxinerama \
    libxcursor \
    curl \
    alsa-lib \
    freetype \
    fontconfig \
    hicolor-icon-theme \
    lv2 \
    webkitgtk \
    gtk+3 \
"

SRC_URI = " \
    gitsm://github.com/dsp56300/gearmulator.git;protocol=https;branch=main \
"
# Use a more Yocto-friendly PV that includes the commit hash for git sources
SRCREV = "a236a2ffcd10b627728c0f4b0c481c2d95c07183"
PV = "1.2.3+git${SRCPV}"

S = "${WORKDIR}/git"

# Pass extra CMake options using EXTRA_OECMAKE.
EXTRA_OECMAKE = " -DJUCE_BUILD_HELPER_TOOLS=OFF -Dgearmulator_BUILD_JUCEPLUGIN_LV2=ON -Dgearmulator_BUILD_JUCEPLUGIN_CLAP=OFF"
# If you specifically need Release *only*, you can set
BUILD_TYPE = "Release"

CXXFLAGS += "-I${STAGING_INCDIR} -DJUCE_BUILD_HELPER_TOOLS=OFF"
LDFLAGS += "-L${STAGING_LIBDIR}"

# bin/plugins/Release/LV2/
# LV2  VST  VST3
FILES:${PN} += "${libdir}/lv2"
