BBCLASSEXTEND = "native"

DEPENDS:class-native = "qtbase-native sip3-native python3-native"

PYQT_MODULES:class-native = "QtCore"

# This is a copy from meta-qt5 adjusted to native staging
do_configure:prepend:class-native() {
    cd ${S}
    echo "py_platform = linux" > pyqt.cfg
    echo "py_inc_dir = %(sysroot)/$includedir/python%(py_major).%(py_minor)${PYTHON_ABI}" >> pyqt.cfg
    echo "py_pylib_dir = %(sysroot)/${libdir}/python%(py_major).%(py_minor)" >> pyqt.cfg
    echo "py_pylib_lib = python$%(py_major).%(py_minor)" >> pyqt.cfg
    echo "pyqt_module_dir = ${D}/${libdir}/python%(py_major).%(py_minor)/site-packages" >> pyqt.cfg
    echo "pyqt_bin_dir = ${D}/${bindir}" >> pyqt.cfg
    echo "pyqt_sip_dir = ${D}/${datadir}/sip/PyQt5" >> pyqt.cfg
    echo "pyuic_interpreter = ${D}/${bindir}/python%(py_major).%(py_minor)" >> pyqt.cfg
    echo "pyqt_disabled_features = ${DISABLED_FEATURES}" >> pyqt.cfg
    echo "qt_shared = True" >> pyqt.cfg
    QT_VERSION=`${OE_QMAKE_QMAKE} -query QT_VERSION`
    echo "[Qt $QT_VERSION]" >> pyqt.cfg
    echo "pyqt_modules = ${PYQT_MODULES}" >> pyqt.cfg
    echo yes | ${PYTHON} configure.py --verbose --qmake  ${STAGING_BINDIR_NATIVE}/${QT_DIR_NAME}/qmake --configuration pyqt.cfg --sysroot ${STAGING_DIR_NATIVE}

    qmake5_base_do_configure

    # avoid running code prepended by recipe
    return 0
}

CFLAGS:append:class-native = " -I${STAGING_INCDIR_NATIVE}/${PYTHON_DIR}"
CXXFLAGS:append:class-native = " -I${STAGING_INCDIR_NATIVE}/${PYTHON_DIR}"

do_install:class-native() {
    cd ${S}
    oe_runmake MAKEFLAGS='-j 1' install

    # should be done for target either...
    for file in `find ${D}${bindir} -name 'py*5'`; do
        echo "Remove abs path in $file..."
        sed -i 's:exec.*${PYTHON_DIR}:exec ${PYTHON_PN}:g' "$file"
    done
}

RDEPENDS:${PN}:class-native = ""

