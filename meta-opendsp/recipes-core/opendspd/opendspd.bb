SUMMARY = "Orchestrator daemon of OpenDSP OS."
HOMEPAGE = "https://github.com/midilab/opendspd"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=d32239bcb673463ab874e80d47fae504"

#DEPENDS = "liblo"

SRC_URI = "git://github.com/midilab/opendspd.git;protocol=https;nobranch=1"

# version
PV = "v0.10"
# commit
SRCREV = "e4120356ebbcf46b178a8d17ca394c0242d5c045"

S = "${WORKDIR}/git"

inherit setuptools3

#do_install() {
#    install -vD opendsp-daemon   -m 0755 ${D}${bindir}
#}