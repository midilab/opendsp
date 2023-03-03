SUMMARY = "Recipe to embedded the Python PiP Package pyliblo"
HOMEPAGE ="https://pypi.org/project/pyliblo"
LICENSE = "LGPL"
LIC_FILES_CHKSUM = "file://NEWS;md5=5cf82a2087a190ad35d15ff72cb071bd"

PYPI_PACKAGE = "pyliblo"
SRC_URI[md5sum] = "1be68794dedaf8cc60748fe94fdb9628"
SRC_URI[sha256sum] = "fc67f1950b827272b00f9f0dc4ed7113c0ccef0c1c09e9976dead40ebbf1798f"

RDEPENDS:${PN} = " \
	liblo\
"

DEPENDS += " \
    python3-cython-native liblo\
"

inherit pypi setuptools3 