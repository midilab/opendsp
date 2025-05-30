SUMMARY = "Recipe to embedded the Python PiP Package rtmidi"
HOMEPAGE ="https://pypi.org/project/rtmidi"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://setup_pkechomidi.py;md5=2e6339c4898996525a11f81a0653e4ac"

PYPI_PACKAGE = "rtmidi"

SRC_URI += "file://fix_rtmidi_build.patch"

SRC_URI[sha256sum] = "bc1e40c24f7df052df9b1e586b82a6987f899ae1a8596ec682af662df275e9b0"

inherit pypi python_setuptools_build_meta

DEPENDS += "alsa-lib"
