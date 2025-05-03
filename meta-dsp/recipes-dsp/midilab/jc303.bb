SUMMARY = "JC303"
HOMEPAGE = "https://midilab.co/jc303/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=903d0fc86333f132c49874fae0bc8c62"

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

SRC_URI = "gitsm://github.com/midilab/jc303.git;protocol=https;branch=main"
SRCREV = "6e7caceb0d221682c301a0aab389691fd56644eb"
PV = "0.12.0"

S = "${WORKDIR}/git"

# Pass extra CMake options using EXTRA_OECMAKE.
#EXTRA_OECMAKE = "-Dgui=midilab"
EXTRA_OECMAKE = " \
    -DJUCE_BUILD_HELPER_TOOLS=ON \
    -DJUCE_BUILD_CONFIGURATION=RELEASE \
    -DCMAKE_BUILD_TYPE=Release \
    -DFETCHCONTENT_FULLY_DISCONNECTED=OFF \
"
BUILD_TYPE = "Release"

# Since this projet makes use of cmake FetchContent we need network access for configrue
do_configure[network] =  "1"

# Set GIT_SSL_NO_VERIFY environment variable for configure task
do_configure:prepend() {
    export GIT_SSL_NO_VERIFY=true
}

# Install the built plugins
do_install () {
    # Define the source directory where CMake/JUCE placed the build artefacts
    local artefacts_dir="${B}/JC303_artefacts/Release"

    # Check if the main artefacts directory exists
    if [ ! -d "${artefacts_dir}" ]; then
        bberror "Artefacts directory not found: ${artefacts_dir}"
        exit 1
    fi

    bbnote "Checking for plugins in ${artefacts_dir}"

    # --- Install LV2 plugins ---
    local src_lv2_dir="${artefacts_dir}/LV2"
    local tgt_lv2_dir="${D}${libdir}/lv2"
    if [ -d "${src_lv2_dir}" ]; then
        bbnote "Installing LV2 plugins to ${tgt_lv2_dir}"
        install -d "${tgt_lv2_dir}"
        # Find *.lv2 dirs inside src_lv2_dir and copy them recursively
        find "${src_lv2_dir}" -maxdepth 1 -type d -name "*.lv2" -exec cp -r {} "${tgt_lv2_dir}/" \;
    else
        bbnote "No LV2 directory found at ${src_lv2_dir}"
    fi

    # --- Install VST (VST2) plugins ---
    local src_vst_dir="${artefacts_dir}/VST"
    local tgt_vst_dir="${D}${libdir}/vst"
    if [ -d "${src_vst_dir}" ]; then
        bbnote "Installing VST plugins to ${tgt_vst_dir}"
        install -d "${tgt_vst_dir}"
        # Find *.so files inside src_vst_dir and install them with execute permissions
        find "${src_vst_dir}" -maxdepth 1 -type f -name "*.so" -exec install -m 0755 {} "${tgt_vst_dir}/" \;
    else
        bbnote "No VST directory found at ${src_vst_dir}"
    fi

    # --- Install VST3 plugins ---
    local src_vst3_dir="${artefacts_dir}/VST3" # Assuming JUCE default is VST3
    local tgt_vst3_dir="${D}${libdir}/vst3"
    if [ -d "${src_vst3_dir}" ]; then
        bbnote "Installing VST3 plugins to ${tgt_vst3_dir}"
        install -d "${tgt_vst3_dir}"
        # Find *.vst3 bundles inside src_vst3_dir and copy them recursively
        find "${src_vst3_dir}" -maxdepth 1 -type d -name "*.vst3" -exec cp -r {} "${tgt_vst3_dir}/" \;
    else
        bbnote "No VST3 directory found at ${src_vst3_dir}"
    fi

    # --- Install CLAP plugins ---
    #local src_clap_dir="${artefacts_dir}/CLAP"
    #local tgt_clap_dir="${D}${libdir}/clap"
    #if [ -d "${src_clap_dir}" ]; then
    #    bbnote "Checking for CLAP files in ${src_clap_dir}"
    #    # Check if the directory is actually empty before proceeding
    #    if [ -n "$(ls -A "${src_clap_dir}")" ]; then
    #        bbnote "Installing CLAP files to ${tgt_clap_dir}"
    #        install -d "${tgt_clap_dir}"
    #        # Find files ending in .clap directly inside src_clap_dir
    #        # and install them with execute permissions (0755)
    #        find "${src_clap_dir}" -maxdepth 1 -type f -name "*.clap" -exec install -m 0755 {} "${tgt_clap_dir}/" \;
    #
    #        # Optional: Add a check to see if anything was actually installed
    #        if [ -z "$(ls -A "${tgt_clap_dir}")" ]; then
    #          bbwarn "CLAP source directory (${src_clap_dir}) contained files, but find command failed to install any *.clap files."
    #        fi
    #    else
    #        bbnote "CLAP source directory (${src_clap_dir}) exists but is empty."
    #    fi
    #else
    #    bbnote "No CLAP source directory found at ${src_clap_dir}"
    #fi
    # --- Remove CLAP plugins ---
    # Ensure CLAP plugin isn't installed or packaged, even if built.
    local src_clap_dir="${artefacts_dir}/CLAP"
    if [ -d "${src_clap_dir}" ]; then
        bbnote "Removing built CLAP plugins from build directory: ${src_clap_dir}"
        # Remove the CLAP directory from the build artifacts directory (${B})
        # Do NOT remove from ${D} as we aren't installing it there anymore.
        rm -rf "${src_clap_dir}"
    else
        bbnote "No CLAP source directory found to remove at ${src_clap_dir}"
    fi

    # Create skel directory structure and symbolic link for runtime user data
    install -d ${D}${sysconfdir}/skel/data/app/midilab/jc303
    install -d ${D}${sysconfdir}/skel/Documents/midilab
    ln -sf ../../data/app/midilab/jc303 ${D}${sysconfdir}/skel/Documents/midilab/JC303
}

FILES_${PN} += " \
    ${libdir}/lv2 \
    ${libdir}/vst \
    ${libdir}/vst3 \
    ${sysconfdir}/skel \
"
