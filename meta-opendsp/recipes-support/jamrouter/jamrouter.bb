SUMMARY = "JAMRouter - JACK and ALSA MIDI event router/processor"
DESCRIPTION = "A low-latency low-jitter ALSA MIDI to Jack MIDI bridge, hardware MIDI compatibility layer and event processor."
HOMEPAGE = "https://github.com/williamweston/jamrouter"
SECTION = "multimedia"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRCREV = "${AUTOREV}"
PV = "0.2.3+git${SRCPV}"

# Add the files directory to FILESPATH
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI = "git://github.com/williamweston/jamrouter.git;protocol=https;branch=master \
           file://child_signal.patch \
"

S = "${WORKDIR}/git"

DEPENDS = "glib-2.0 alsa-lib jack"

inherit autotools pkgconfig

# TODO: later make it dinamicly pickup based on MACHINE
ARCH = "x86_64"

EXTRA_OECONF = "-enable-arch=${ARCH} --without-lash --without-juno"

do_configure:append() {
    # Remove -m32 flags for arm/32bit, fix mfence typo, port mfence to dmb for ARM
    find . -type f | xargs sed -i 's/\-m32 / /g'
    find . -type f | xargs sed -i 's/ mfence/mfence/g'
    find . -type f | xargs sed -i 's/mfence; # read\/write fence/dmb/g'
    # Prevent config.status --recheck from undoing our work
    sed -i 's/config.status \-\-recheck/config.status/g' Makefile || true
    sed -i 's/config.status \-\-recheck/config.status/g' Makefile.in || true
}

FILES_${PN} += "${bindir}/* ${datadir}/*"

INSANE_SKIP_${PN} = "ldflags"
