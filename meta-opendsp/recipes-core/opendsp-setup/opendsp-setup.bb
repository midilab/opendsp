SUMMARY = "Configuration files and setup for OpenDSP"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

# Point SRC_URI to the 'etc' directory within 'files/' relative to the recipe path.
# BitBake will copy this 'etc' directory into ${WORKDIR}
SRC_URI = " \
    file://etc \
"

do_install() {
    install -d ${D}${sysconfdir}
    install -m 0644 ${S}/etc/create_ap.conf ${D}${sysconfdir}/create_ap.conf
    # Handle the 'skel' directory
    if [ -d ${S}/etc/skel ]; then
        install -d -m 0755 ${D}${sysconfdir}/skel
        cp -r ${S}/etc/skel/. ${D}${sysconfdir}/skel/
        chown -R root:root ${D}${sysconfdir}/skel
        chmod -R u=rwX,go=rX ${D}${sysconfdir}/skel
    fi
    # Install resize_userdata script
    install -D ${WORKDIR}/resize_userdata -m 0777 ${D}${bindir}/resize_userdata
}

FILES:${PN} += " \
    ${sysconfdir}/skel \
    ${sysconfdir}/skel/* \
    ${sysconfdir}/create_ap.conf \
"

CONFFILES:${PN} = " \
    ${sysconfdir}/create_ap.conf \
"
