SUMMARY = "JC303"
HOMEPAGE = "https://midilab.co/jc303/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=903d0fc86333f132c49874fae0bc8c62"

# Inherit cmake for build system, pkgconfig for dependency detection,
# and pack_audio_plugins to handle LV2 packaging.
inherit cmake pkgconfig pack_audio_plugins native

# Add dependencies:
# - JUCE requires X11 libs, ALSA, FreeType, Fontconfig
# - Building LV2 plugins requires lv2 headers/libs
DEPENDS = " \
    xorgproto \
    libx11-native libxinerama-native libxrandr-native libxcursor-native \
    alsa-lib-native freetype-native fontconfig \
    lv2 \
    curl \
    webkitgtk \
    gtk+3 \
"
REQUIRED_DISTRO_FEATURES = "x11"

SRC_URI = " \
    gitsm://github.com/midilab/jc303.git;protocol=https;branch=main \
"
# Use a more Yocto-friendly PV that includes the commit hash for git sources
SRCREV = "6e7caceb0d221682c301a0aab389691fd56644eb"
PV = "0.12.0+git${SRCPV}"

S = "${WORKDIR}/git"

# Pass extra CMake options using EXTRA_OECMAKE.
#EXTRA_OECMAKE = "-Dgui=midilab"
# If you specifically need Release *only*, you can set
BUILD_TYPE = "Release"

# Since this projet makes use of cmake FetchContent we need network access for configrue
#EXTRA_OECMAKE:append = "-DFETCHCONTENT_FULLY_DISCONNECTED=OFF -DGIT_SSL_NO_VERIFY=true"
#do_configure[network] =  "1"
#do_compile[network] = "1"

# If the main 'gearmulator' executable is installed by 'make install'
# to ${bindir}, it will be packaged in the main ${PN} package by default.
# If it's *not* installed by default, or you want to be explicit:
FILES_${PN} += "${bindir}/jc303"
