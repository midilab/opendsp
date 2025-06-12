# Add the machine-specific X11 configuration file to the source URI
SRC_URI += "file://20-${MACHINE}.conf"

# Add the files directory to FILESPATH
FILESPATH:prepend := "${THISDIR}/files:"

# Install the configuration file to the appropriate directory
do_install:append() {
    install -d ${D}/usr/share/X11/xorg.conf.d
    install -m 0644 ${WORKDIR}/20-${MACHINE}.conf ${D}/usr/share/X11/xorg.conf.d/
}

FILES:${PN} += "/usr/share/X11/xorg.conf.d/20-${MACHINE}.conf"
