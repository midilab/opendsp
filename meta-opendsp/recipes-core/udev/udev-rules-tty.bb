DESCRIPTION = "udev rules for tty access"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI = "file://tty.rules"

S = "${WORKDIR}"

do_install () {
    install -d ${D}${sysconfdir}/udev/rules.d/
    install -m 0644 tty.rules ${D}${sysconfdir}/udev/rules.d/
}

