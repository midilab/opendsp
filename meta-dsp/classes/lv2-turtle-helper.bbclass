# Helper class to handle creation of lv2 turtle files

# Turtle files (*.ttl) are created during compile usually. This does not work
# for us because cross build libraries cannot be opened by build host. To get
# around we:
#
# 1. Adjust build (see do_ttl_sed) so that instead calling LV2_TTL_GENERATOR
#    the plugin file name is written to LV2_PLUGIN_INFO_FILE
# 2. Try to generate ttl with the help of qemu. This can faile for various
#    reasons: SIMD instructions not supported / qemu itself / ...
#    For files not handled properly we try:
# 3. Generate ttl-files at first boot / after package was installed


# File containing names of plugins to handle in do_compile:append 
# Line-format expected: <some-path-in-build>/<plugin>.so
LV2_PLUGIN_INFO_FILE = "${WORKDIR}/lv2-ttl-generator-data"
LV2_PLUGIN_INFO_FILE_CLEANED = "${LV2_PLUGIN_INFO_FILE}-cleaned"

# File containing names of plugins to handle in do_compile:append 
# Line-format expected: <path-ontarget>/<plugin>.so
LV2_PLUGIN_POSTINST_INFO_FILE = "${LV2_PLUGIN_INFO_FILE}-postinst"

# To make ontarget postinst/prerm happen, the names of all plugins with their
# paths as installed on target a stored in a file called lv2-postinst-manifest
LV2_POSTINST_MANIFEST = "${datadir}/${BPN}/lv2-postinst-manifest"

# Path to the ttl-generator qemu will use. Since most plugins are based on dpf
# (added by git-submodule) we can set a default matchin > 80%+
LV2_TTL_GENERATOR ?= "${S}/dpf/utils/lv2_ttl_generator"

inherit qemu-ext-musicians audio-plugin-common

# override this function and execute sed (or other magic) to adjust Makefiles
# so that lv2-ttl-generator is not executed but plugin information. Same here:
# Set default match many dpf-based plugins
do_ttl_sed() {
    sed -i 's|"$GEN" "./$FILE"|echo "`realpath  "./$FILE"`" >> ${LV2_PLUGIN_INFO_FILE}|g' ${S}/dpf/utils/generate-ttl.sh
}

do_configure:prepend() {
    # 1st configure?
    if [ ! -f ${LV2_PLUGIN_INFO_FILE} ]; then
        do_ttl_sed
    fi
}

do_compile:prepend() {
    # remove plugin-info from previous build
    rm -f ${LV2_PLUGIN_INFO_FILE}
    rm -f ${LV2_PLUGIN_POSTINST_INFO_FILE}
}

do_compile[vardeps] += "LV2_TTL_GENERATOR"
do_compile:append() {
    rm -f ${LV2_PLUGIN_INFO_FILE_CLEANED}
    if [ -e ${LV2_PLUGIN_INFO_FILE} ]; then
        echo
        echo "---------- start of lv2 ttl generation ----------"
        echo "lv2-plugins found - try ttl-generation with LV2_TTL_GENERATOR: '${LV2_TTL_GENERATOR}'"
        # try build ttl-files with quemu
        for sofile in `sort ${LV2_PLUGIN_INFO_FILE} | uniq`; do
            echo $sofile >> ${LV2_PLUGIN_INFO_FILE_CLEANED}
            sobase=`basename $sofile`
            ttl_failed=""
            if [ "x${ttl_failed}" = "x" ]; then
                cd `dirname ${sofile}`
                echo "QEMU lv2-ttl-generator for ${sofile}..."
                ${@qemu_run_binary_local(d, '${STAGING_DIR_TARGET}', '${LV2_TTL_GENERATOR}')} ${sofile} || ttl_failed="$?"
                if [ "x${ttl_failed}" = "x" ]; then
                    echo "Generation succeeded."
                else
                    if [ "x${ttl_failed}" = "x124" ]; then
                        echo "ERROR: ttl-generation for `basename ${sofile}` timed out!"
                    else
                        echo "ERROR: ttl-generation for `basename ${sofile}` failed!"
                        echo "LV2_TTL_GENERATOR set correctly - check few lines above?"
                        # qemu failed: remove generated core files
                        rm -f *.core
                    fi
                fi
            fi
            if [ "x${ttl_failed}" != "x" ]; then
                # postpone on target
                echo `basename $sofile` >> ${LV2_PLUGIN_POSTINST_INFO_FILE}
            fi
        done
    else
        echo
        echo "LV2_PLUGIN_INFO_FILE was not created during compilation - check do_ttl_sed() or patch postponing ttl-generation"
        echo
        exit -1
    fi
}
do_compile[postfuncs] += "do_ttl_qa"
python do_ttl_qa() {
    lv2_plugin_postinst_info_file = d.getVar('LV2_PLUGIN_POSTINST_INFO_FILE')
    if os.path.isfile(lv2_plugin_postinst_info_file):
        lv2_plugin_info_file_cleaned = d.getVar('LV2_PLUGIN_INFO_FILE_CLEANED')
        num_plugins = len(open(lv2_plugin_info_file_cleaned).readlines())
        num_plugins_postinst = len(open(lv2_plugin_postinst_info_file).readlines())
        name = d.getVar('PN')
        if num_plugins == num_plugins_postinst:
            bb.warn("All LV2-plugins in %s are postponed to post-install! Check log.do_compile for valid LV2_TTL_GENERATOR (%s)" % (name,d.getVar('LV2_TTL_GENERATOR')))
        else:
            bb.warn("%i of %i LV2-plugins in %s are postponed to post-install! Check %s and log.do_compile for details" % (num_plugins_postinst, num_plugins, name, lv2_plugin_postinst_info_file))
}

do_install:append() {
    # create postinst manifest
    if [ -e ${LV2_PLUGIN_POSTINST_INFO_FILE} ]; then
        install -d ${D}`dirname ${LV2_POSTINST_MANIFEST}`
        for sofile in `cat ${LV2_PLUGIN_POSTINST_INFO_FILE}`; do
            installed=`find ${D}${libdir}/lv2 -name $sofile | sed 's|${D}||g'`
            echo $installed >> ${D}${LV2_POSTINST_MANIFEST}
        done
    fi
}

pkg_postinst_ontarget:${PN_LV2}() {
    if [ -e ${LV2_POSTINST_MANIFEST} ]; then
        oldpath=`pwd`
        for sofile in `cat ${LV2_POSTINST_MANIFEST}`; do
            lv2_path=`dirname "$sofile"`
            cd "$lv2_path"
            if ! lv2-ttl-generator "$sofile"; then
                echo "Error: Turtle files for $sofile could not be created - remove $lv2_path!"
                cd ..
                rm -rf "$lv2_path"
            fi
        done
        cd $oldpath
    fi
}

pkg_prerm:${PN_LV2}() {
    if [ -e ${LV2_POSTINST_MANIFEST} ]; then
        for sofile in `cat ${LV2_POSTINST_MANIFEST}`; do
            path=`dirname "$sofile"`
            for turtle in `find $path -name '*.ttl'`; do
                rm $turtle
            done
        done
    fi
}

FILES:${PN_LV2} += "${LV2_POSTINST_MANIFEST}"
RDEPENDS:${PN_LV2} += "lv2-ttl-generator"
