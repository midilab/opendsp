FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " file://opendsp-smb.conf"

do_install:append() {
    install -m 0644 ${WORKDIR}/sources-unpack/opendsp-smb.conf ${D}${sysconfdir}/samba/smb.conf
}
