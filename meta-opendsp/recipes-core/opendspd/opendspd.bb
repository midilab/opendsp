SUMMARY = "Orchestrator daemon of OpenDSP OS."
HOMEPAGE = "https://github.com/midilab/opendspd"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://../LICENSE;md5=d32239bcb673463ab874e80d47fae504"

# default user to run opendspd is opendsp
OPENDSP_HOME_DIR = "/home/opendsp"

SRC_URI = " \
    git://github.com/midilab/opendspd.git;protocol=https;nobranch=1 \
    file://first-boot-setup.sh \
    file://first-boot-setup.service \
    file://changepasswd \
    file://resize_userdata \
    file://passdb.tdb \
"

# version
PV = "v0.14.2"
# commit
SRCREV = "a2dbbdb725f8fe53eeeb615eb4894f5f77534dfa"

S = "${WORKDIR}/git/src"

FILES:${PN} += "${bindir}/*"
FILES:${PN} += "${sbindir}/*"
FILES:${PN} += "${sysconfdir}/*"
FILES:${PN} += "${systemd_system_unitdir}/*"
FILES:${PN} += "${OPENDSP_HOME_DIR}/.*"
FILES:${PN} += "${OPENDSP_HOME_DIR}/*"

RDEPENDS:${PN} = " \
    alsa-utils \
    jack-server \
    a2jmidid \
	python3-pyliblo \
    python3-rtmidi \
    python3-jack-client \
    python3-mididings \
    sudo \
    bash \
"

#
# service
#
inherit systemd
# create_ap.service
NATIVE_SYSTEMD_SUPPORT = "1"
SYSTEMD_PACKAGES += "${PN}"
SYSTEMD_SERVICE:${PN} += " opendsp.service first-boot-setup.service"
SYSTEMD_AUTO_ENABLE = "enable"

do_install:append() {
    # opendsp entrypoint
    install -D opendsp-daemon -m 0755 ${D}${bindir}/opendspd

    # opendsp services
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ../services/opendsp.service ${D}${systemd_system_unitdir}/
    install -m 0644 ../services/vdisplay.service ${D}${systemd_system_unitdir}/
    install -m 0644 ../services/display.service ${D}${systemd_system_unitdir}/

    # first boot setup
    install -m 0644 ${WORKDIR}/first-boot-setup.service ${D}${systemd_system_unitdir}/
    install -d ${D}${sbindir}
    install -m 0755 ${WORKDIR}/first-boot-setup.sh ${D}${sbindir}/
    install -d ${D}${bindir}
    install -D ${WORKDIR}/resize_userdata -m 0777 ${D}${bindir}/

    # opendsp user skel data
    install -d ${D}${OPENDSP_HOME_DIR}/.config/openbox/
    cp -rf --no-preserve=ownership ../skel/openbox/* ${D}${OPENDSP_HOME_DIR}/.config/openbox/
    install -d ${D}${OPENDSP_HOME_DIR}/.config/tint2/
    cp -rf --no-preserve=ownership ../skel/tint2/* ${D}${OPENDSP_HOME_DIR}/.config/tint2/
    install -d ${D}${OPENDSP_HOME_DIR}/.local/share/applications/
    cp -rf --no-preserve=ownership ../skel/applications/* ${D}${OPENDSP_HOME_DIR}/.local/share/applications/

    # opendsp tools
    install -d ${D}${OPENDSP_HOME_DIR}/.config/openbox/scripts/
    cp -rf --no-preserve=ownership ../tools/openbox/scripts/*.py ${D}${OPENDSP_HOME_DIR}/.config/openbox/scripts/
    install -D ../tools/bin/opendspd-update -m 0755 ${D}${bindir}/opendspd-update
    install -D ../tools/bin/vlc-youtube-update -m 0755 ${D}${bindir}/vlc-youtube-update

    # opendsp user data
    install -d ${D}${OPENDSP_HOME_DIR}/data/
    cp -rf --no-preserve=ownership ../data/* ${D}${OPENDSP_HOME_DIR}/data/

    # apps and tools symbolic linkage for read-only fs support
    install -d ${D}${OPENDSP_HOME_DIR}/.log/a2j/
    install -d ${D}${OPENDSP_HOME_DIR}/.config/a2j/

    # changepasswd file
    install -D ${WORKDIR}/changepasswd -m 0755 ${D}${bindir}/

    # because samba couldn't get password updated at boot time we preset a default one file
    # TODO: find a fix! this is a security issue to host this file on repository
    mkdir -p ${D}/var/lib/samba/private/
    install -D ${WORKDIR}/passdb.tdb -m 0600 ${D}/var/lib/samba/private/
}

inherit setuptools3
