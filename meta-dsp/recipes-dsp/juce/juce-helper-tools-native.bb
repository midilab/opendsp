SUMMARY = "JUCE's helper tools for cross-compile builds"
HOMEPAGE = "https://juce.com/"
LICENSE = "GPL-3.0-only"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=d59a7366348d00ae0ce345b63ee61ff0"

# Inherit cmake for build system
inherit cmake pkgconfig native

# Dependencies required to build JUCE helper tools
DEPENDS += " \
    libx11-native \
    libxrandr-native \
    libxext-native \
    libxinerama-native \
    libxcursor-native \
    curl-native \
    freetype-native \
    alsa-lib-native \
"

SRC_URI = "gitsm://github.com/dsp56300/JUCE.git;protocol=https;branch=dsp56300_7.0.10 \
           file://juce-crosscompile.patch \
"
SRCREV = "bf39bb3916cf6e5858a53831440eb1e58e5fb095"

S = "${WORKDIR}/git"

EXTRA_OECMAKE = " \
    -DJUCE_BUILD_TOOLS=ON \
    -DJUCE_BUILD_EXTRAS=OFF \
    -DJUCE_BUILD_EXAMPLES=OFF \
    -DJUCE_BUILD_CONFIGURATION=RELEASE \
    -DCMAKE_BUILD_TYPE=Release \
"

BUILD_TYPE = "Release"
