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
    juce-helper-tools-native \
    alsa-lib \
    freetype \
    fontconfig \
    hicolor-icon-theme \
    lv2 \
    webkitgtk \
    gtk+3 \
"

SRC_URI = "gitsm://github.com/dsp56300/gearmulator.git;protocol=https;branch=main"
SRCREV = "a236a2ffcd10b627728c0f4b0c481c2d95c07183"
PV = "1.2.3"

S = "${WORKDIR}/git"

# Pass extra CMake options using EXTRA_OECMAKE.
EXTRA_OECMAKE = " \
    -DJUCE_BUILD_HELPER_TOOLS=ON \
    -DJUCE_BUILD_CONFIGURATION=RELEASE \
    -DCMAKE_BUILD_TYPE=Release \
    -Dgearmulator_BUILD_JUCEPLUGIN_LV2=ON \
    -Dgearmulator_BUILD_JUCEPLUGIN_CLAP=OFF \
    -Dgearmulator_BUILD_JUCEPLUGIN_VST2=OFF \
    -Dgearmulator_BUILD_JUCEPLUGIN_VST3=OFF \
    -Dgearmulator_BUILD_JUCEPLUGIN_AU=OFF \
"

BUILD_TYPE = "Release"

do_compile:prepend() {
    # linking juceaide native tools for crosscompile
    # The build system seems to look for juce::juceaide specifically.
    ln -sf ${STAGING_DIR_NATIVE}/${bindir_native}/juceaide ${STAGING_DIR_NATIVE}/${bindir_native}/juce\:\:juceaide

    # Operate in the native sysroot directory
    BIN_DIR=${STAGING_DIR_NATIVE}/${bindir_native}

    # Rename the original binary and create a wrapper script for juce_vst3_helper
    mv ${BIN_DIR}/juce_vst3_helper ${BIN_DIR}/juce_vst3_helper.bin
    cat > ${BIN_DIR}/juce_vst3_helper << 'EOF'
#!/bin/sh
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$SCRIPT_DIR/../lib:$LD_LIBRARY_PATH"
"$SCRIPT_DIR/juce_vst3_helper.bin" "$@"
EOF
    chmod +x ${BIN_DIR}/juce_vst3_helper

    # Repeat for other helper tools if needed
    mv ${BIN_DIR}/juce_lv2_helper ${BIN_DIR}/juce_lv2_helper.bin
    cat > ${BIN_DIR}/juce_lv2_helper << 'EOF'
#!/bin/sh
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
export LD_LIBRARY_PATH="$SCRIPT_DIR/../lib:$LD_LIBRARY_PATH"
"$SCRIPT_DIR/juce_lv2_helper.bin" "$@"
EOF
    chmod +x ${BIN_DIR}/juce_lv2_helper
}

do_install:append() {
    # Remove unwanted files from the image directory
    rm -rf ${D}/usr/start_IndiArp_BC.sh
    rm -rf ${D}/usr/start_Impact__MS.sh
    rm -rf ${D}/usr/dsp56300EmuServer
    rm -rf ${D}/usr/mqPerformanceTest
    rm -rf ${D}/usr/virusTestConsole
    rm -rf ${D}/usr/plugins
}

# Specify the files to include in the package
FILES:${PN} += "${libdir}/lv2"
