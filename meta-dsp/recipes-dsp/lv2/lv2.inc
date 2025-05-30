SUMMARY = "LV2 is an open standard for audio plugins"
LICENSE = "ISC"
LIC_FILES_CHKSUM = "file://COPYING;md5=0383f162366b0c5a316292759a55d292"

SRC_URI = " \
    gitsm://github.com/lv2/lv2.git;branch=main;protocol=https \
    file://0001-Output-more-details-on-import-error-to-catch-missing.patch \
    file://0002-Fix-build-for-python3-only-environments.patch \
"
S = "${WORKDIR}/git"
SRCREV = "cd152104c84bcee9fec22ef780cec2af7ba85d0c"
PV = "1.18.2"

inherit waf pkgconfig
