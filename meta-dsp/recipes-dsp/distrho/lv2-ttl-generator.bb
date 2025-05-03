SUMMARY = "lv2-ttl-generator-native"
LICENSE = "ISC"
LIC_FILES_CHKSUM = " \
    file://LICENSE;md5=87cb0d450c5426796754d1261693dc57 \
"

SRC_URI = "git://github.com/DISTRHO/DPF.git;protocol=https;branch=master"
SRCREV = "14842be64ba309b8717592c5cf461925fa8a98af"
S = "${WORKDIR}/git"
PV = "0.0.0+git${SRCPV}"

BBCLASSEXTEND = "native"

do_compile() {
    cd ${S}/utils/lv2-ttl-generator
    oe_runmake
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ${S}/utils/lv2_ttl_generator ${D}${bindir}/lv2-ttl-generator
}

# There are cases we neet we need target versions
SYSROOT_DIRS:append:class-target = " ${bindir}"

