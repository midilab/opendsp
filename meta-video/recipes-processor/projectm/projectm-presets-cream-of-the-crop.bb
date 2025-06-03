SUMMARY = "projectM - Cream of the Crop Presets"
HOMEPAGE = "https://github.com/projectM-visualizer/presets-cream-of-the-crop"
LICENSE = "CC0-1.0"
LIC_FILES_CHKSUM = "file://LICENSE.md;md5=200d7a7c8c8ea75abe63792f19727bb8"

SRC_URI = " \
    https://github.com/projectM-visualizer/presets-cream-of-the-crop/archive/refs/heads/master.zip;name=presets \
"
SRC_URI[presets.md5sum] = "3fda795ad960c084cf9d36ca01c3d8b8"

S = "${WORKDIR}/presets-cream-of-the-crop-master"

inherit allarch

do_install() {
    install -d ${D}${datadir}/projectM/presets
    rm -f ${S}/LICENSE.md
    rm -f ${S}/README.md

    # Recursively install all directories
    cd ${S}
    find . -type d -exec install -d ${D}${datadir}/projectM/presets/{} \;

    # Recursively install all files
    find . -type f -exec install -m 0644 {} ${D}${datadir}/projectM/presets/{} \;
}

FILES:${PN} += " \
    ${datadir}/projectM/presets/ \
"
