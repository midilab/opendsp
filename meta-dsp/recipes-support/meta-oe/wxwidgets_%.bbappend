# Will did send this to meta-oe master but don't expect to get it into dunfell.
# So do the necessary changes in a way that is compatibile to meta-oe dunfell
# and master

inherit binconfig

PACKAGECONFIG:append = " ${@bb.utils.filter('DISTRO_FEATURES', 'opengl', d)}"
PACKAGECONFIG[opengl] = ",,libglu"

do_patch[postfuncs] += "do_patch_nocross"
do_patch_nocross() {
    # This one will be patched in meta-oe but we cannot do same
    sed -i 's:@cross_compiling@:no:g' ${S}/wx-config.in
}

do_compile:append() {
    if [ -L ${B}/wx-config ]; then
        echo "wxwidget recipe is not yet updated to wx-config adjustments so we do"
        # ${B}/wx-config is a symlink for build and not needed after compile
        # So for our purposes do:
        # 1. make a file out of wx-config so that binconfig.bbclass detects it
        # 2. make sure we do not move the file used for compiling into sysroot
        cp --remove-destination `readlink ${B}/wx-config | sed 's:inplace-::'` ${B}/wx-config
    fi
    # 3. Set full sysroot paths so sstate can translate them when setting
    #    up wxwidgets's consumer sysroots
    sed -i \
        -e 's,^includedir=.*,includedir="${STAGING_INCDIR}",g' \
        -e 's,^libdir=.*",libdir="${STAGING_LIBDIR}",g' \
        -e 's,^bindir=.*",bindir="${STAGING_BINDIR}",g' \
        ${B}/wx-config
}

