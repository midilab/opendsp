inherit qemu

DEPENDS:append = " qemu-native coreutils-native"

# This is an extended/modified qemu.bbclass tailored four our needs:
#
# * add qemu-native to DEPENDS: we can do that because there is no
#   introspection/interception delayed qemu usage here
# * The executable binary is set by absolute path: oe-core's qemu.bbclass
#   expects it in sysroot. Here we usually run binaries in builddir which are
#   not yet installed.
# * A recipe can set an extra library path in 'QEMU_EXTRA_LIBDIR'. This path is
#   an absolute path.
# * To catch infine qemu runs we create a wrapper adding timeout  handling
#   and ensuring there is only one qemu instance at a time (we learned in
#   meta-microcontroller/vtk that spawning many qemu instances in short time
#   can lead to zombie processes)

QEMU_TIMEOUT ?= "180"

def qemu_run_binary_local(data, rootfs_path, binary):
    libdir = rootfs_path + data.getVar("libdir")
    base_libdir = rootfs_path + data.getVar("base_libdir")
    extra_libdir = data.getVar("QEMU_EXTRA_LIBDIR")

    if extra_libdir:
        cmdline = qemu_wrapper_cmdline(data, rootfs_path, [libdir, base_libdir, extra_libdir]) + binary
    else:
        cmdline = qemu_wrapper_cmdline(data, rootfs_path, [libdir, base_libdir]) + binary

    return cmdline.replace(qemu_target_binary(data), data.getVar("WORKDIR") + '/' + qemu_target_binary(data) + '-timeout')

create_qemu_ext_wrappers() {
    # create qemu wrappers:
    # * run one instance of qemu at a time
    # * add timeout: run infinite is what makes using qemu suck
    for qemu in `find ${STAGING_BINDIR_NATIVE} -name qemu-*`; do
        qemu_name=`basename $qemu`
        if [ "x${@qemu_target_binary(d)}" = "x$qemu_name" ]; then
            wrapper_name="$qemu_name-timeout"
            echo '#!/bin/sh' > ${WORKDIR}/$wrapper_name
            echo 'set -e' >> ${WORKDIR}/$wrapper_name
            echo "flock ${WORKDIR}/qemu.lock timeout ${QEMU_TIMEOUT} $qemu_name \$@" >> ${WORKDIR}/$wrapper_name
            chmod +x ${WORKDIR}/$wrapper_name
        fi
    done
}
do_configure[prefuncs] += "create_qemu_ext_wrappers"

