SUMMARY = "Orchestrator daemon of OpenDSP OS."
HOMEPAGE = "https://github.com/midilab/opendspd"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://../LICENSE;md5=d32239bcb673463ab874e80d47fae504"

# default user to run opendspd is opendsp
OPENDSP_HOME_DIR = "/home/opendsp"

SRC_URI = "git://github.com/midilab/opendspd.git;protocol=https;nobranch=1"

# version
PV = "v0.10.3"
# commit
SRCREV = "bddf42d4947aeacd9c87e1a980c7bf35059fd2eb"

S = "${WORKDIR}/git/src"

FILES:${PN} = "${bindir}/*"
FILES:${PN} += "${sysconfdir}/*"
FILES:${PN} += "${systemd_system_unitdir}/*"
FILES:${PN} += "${OPENDSP_HOME_DIR}/.*"
FILES:${PN} += "${OPENDSP_HOME_DIR}/*"

RDEPENDS:${PN} = " \
	python3-pyliblo \
    python3-rtmidi \
    python3-jack-client \
    python3-mididings \
    bash \
"

do_install:append() {
    # opendsp entrypoint
    install -D opendsp-daemon -m 0755 ${D}${bindir}/opendspd

    # opendsp services
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ../services/opendsp.service ${D}${systemd_system_unitdir}/
    install -m 0644 ../services/vdisplay.service ${D}${systemd_system_unitdir}/
    install -m 0644 ../services/display.service ${D}${systemd_system_unitdir}/

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
    install -D ../tools/bin/changepasswd -m 0755 ${D}${bindir}/changepassword
    install -D ../tools/bin/opendspd-update -m 0755 ${D}${bindir}/opendspd-update
    install -D ../tools/bin/vlc-youtube-update -m 0755 ${D}${bindir}/vlc-youtube-update

    # opendsp user data
    install -d ${D}${OPENDSP_HOME_DIR}/data/ 
    cp -rf --no-preserve=ownership ../data/* ${D}${OPENDSP_HOME_DIR}/data/
}

inherit systemd

SYSTEMD_SERVICE:${PN} += "opendsp.service"
SYSTEMD_AUTO_ENABLE = "enable"

inherit setuptools3