SUMMARY = "Recipe to embedded the Python PiP Package mididings"
HOMEPAGE ="https://pypi.org/project/mididings"
LICENSE = "GNU-2.0"
LIC_FILES_CHKSUM = "file://README.md;md5=f0f58f50d57bd7496dab1a157dd50174"

PYPI_PACKAGE = "mididings"

SRC_URI[sha256sum] = "b63fa2ec380075f89da72747d83c3e130e4202e545442da44e249b79b751f29a"

RDEPENDS:${PN} = " \
	alsa-lib \
    boost \
"

DEPENDS += " \
    alsa-lib \
    jack \
    boost \
"

inherit setuptools3 pypi pkgconfig 