DESCRIPTION = "Firmware binaries for loader programs in alsa-tools and hotplug firmware loader"
HOMEPAGE = "https://alsa-project.org/"
SECTION = "base/kernel"
LICENSE = "BSD-3-Clause & GPL-2.0-only & LGPL-2.1-only"
LIC_FILES_CHKSUM = " \
    file://COPYING;md5=d2240eee132996e6acef85bb7bc349db \
    file://aica/license.txt;md5=272787adcad53e7d7efe9dc0ce98eefd \
    file://ca0132/creative.txt;md5=6eebfe959056669261275156cc51977d \
"
# file://sb16/LICENSE;md5=YOUR_MD5_CHECKSUM_HERE \ removed?

PV = "1.2.4"
PR = "r4"

SRC_URI = "https://www.alsa-project.org/files/pub/firmware/${BP}.tar.bz2;name=archive"
SRC_URI[archive.sha256sum] = "b67b6d7d08bcfc247ef6ff0ab88a99c188305a3cf57ae2dfd0bcd9a5b36cd5bb"

inherit autotools pkgconfig

EXTRA_OECONF = "--enable-buildfw --with-hotplug-dir=${nonarch_base_libdir}/firmware"

do_configure:prepend() {
    cd ${S}
    autoreconf -fiv
}

do_compile() {
    cd ${S}
    oe_runmake
}

do_install() {
    cd ${S}
    oe_runmake DESTDIR=${D} install

    # Remove files which conflict with linux-firmware or are otherwise unwanted
    rm -rf ${D}${nonarch_base_libdir}/firmware/ctefx.bin
    rm -rf ${D}${nonarch_base_libdir}/firmware/ctspeq.bin
    rm -rf ${D}${nonarch_base_libdir}/firmware/ess
    rm -rf ${D}${nonarch_base_libdir}/firmware/korg
    rm -rf ${D}${nonarch_base_libdir}/firmware/sb16
    rm -rf ${D}${nonarch_base_libdir}/firmware/yamaha

    # Remove broken symlinks (adjust if upstream fixes this)
    rm -rf ${D}${nonarch_base_libdir}/firmware/turtlebeach

    # Install specific license files to the package's license directory
    install -d ${D}${datadir}/licenses/${PN}/aica
    install -m 0644 ${S}/aica/license.txt ${D}${datadir}/licenses/${PN}/aica/

    install -d ${D}${datadir}/licenses/${PN}/ca0132
    install -m 0644 ${S}/ca0132/creative.txt ${D}${datadir}/licenses/${PN}/ca0132/
}

# FILES definition to package the installed firmware, helper files, and licenses
FILES:${PN} += " \
    ${nonarch_base_libdir}/firmware \
    ${datadir}/alsa/firmware \
    ${datadir}/licenses/${PN} \
"

# Skip the architecture QA check because firmware blobs (like .elf for onboard DSPs)
# may not match the host architecture, and the package is marked "all".
INSANE_SKIP:${PN} += "arch"
