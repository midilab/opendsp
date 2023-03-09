SUMMARY = "Recipe to embedded the Python PiP Package rtmidi"
HOMEPAGE ="https://pypi.org/project/rtmidi"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup_pkechomidi.py;md5=2e6339c4898996525a11f81a0653e4ac"

PYPI_PACKAGE = "rtmidi"

SRC_URI[sha256sum] = "f1ffd73d6571e6ce2769d77e247523738605a71c32d8f60b56a3b41002d0d54c"

DEPENDS += "alsa-lib"

inherit pypi python_setuptools_build_meta