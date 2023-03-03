SUMMARY = "Recipe to embedded the Python PiP Package JACK-Client"
HOMEPAGE ="https://pypi.org/project/JACK-Client"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=665c474834cf6a12a7f9cb03ebab8071"

PYPI_PACKAGE = "JACK-Client"
SRC_URI[md5sum] = "de62ca7df7d13907f7c7182f1f115776"
SRC_URI[sha256sum] = "dd4a293e3a6e9bde9972569b9bc4630a5fcd4f80756cc590de572cc744e5a848"

RDEPENDS:${PN} = " \
    python3-cffi\
"

DEPENDS += " \
    python3-cffi\
"

inherit pypi python_setuptools_build_meta
