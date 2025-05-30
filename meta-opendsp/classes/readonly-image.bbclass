# File: meta-opendsp/classes/readonly-rootfs-hack.bbclass
# Generic solution for read-only rootfs package configuration issues

# Default list of problematic packages (can be overridden in recipes)
READONLY_PROBLEMATIC_PACKAGES ??= "systemd-compat-units udev base-files"

# Generic function to temporarily disable read-only during package operations
python do_rootfs_readonly_hack() {
    import os
    image_features = d.getVar('IMAGE_FEATURES') or ""

    if 'read-only-rootfs' in image_features:
        bb.note("=== READONLY ROOTFS HACK: Temporarily disabling read-only for package configuration ===")
        d.setVar('ORIGINAL_IMAGE_FEATURES', image_features)
        new_features = image_features.replace('read-only-rootfs', '').strip()
        new_features = ' '.join(new_features.split())
        d.setVar('IMAGE_FEATURES', new_features)

        # Set lenient environment variables
        os.environ['DEBIAN_FRONTEND'] = 'noninteractive'
        os.environ['SYSTEMCTL_SKIP_REDIRECT'] = '1'
        os.environ['SYSTEMD_IGNORE_CHROOT'] = '1'
        os.environ['DPKG_MAINTSCRIPT_PACKAGE_REFCOUNT'] = '1'

        bb.note(f"Temporarily disabled read-only for packages: {d.getVar('READONLY_PROBLEMATIC_PACKAGES')}")
}

python do_rootfs_readonly_restore() {
    import os
    original_features = d.getVar('ORIGINAL_IMAGE_FEATURES')

    if original_features:
        bb.note("=== READONLY ROOTFS HACK: Restoring read-only rootfs configuration ===")
        d.setVar('IMAGE_FEATURES', original_features)

        rootfs_dir = d.getVar('IMAGE_ROOTFS')
        problematic_packages = d.getVar('READONLY_PROBLEMATIC_PACKAGES').split()
        installed_packages = d.getVar('IMAGE_INSTALL').split()

        for pkg in problematic_packages:
            if pkg in installed_packages or any(pkg in ip for ip in installed_packages):
                bb.note(f"Applying manual fixes for package: {pkg}")

                if pkg == 'systemd-compat-units':
                    systemd_dirs = [
                        'etc/systemd/system/multi-user.target.wants',
                        'etc/systemd/system/graphical.target.wants',
                        'etc/systemd/system/sysinit.target.wants'
                    ]
                    for sdir in systemd_dirs:
                        full_path = os.path.join(rootfs_dir, sdir)
                        os.makedirs(full_path, exist_ok=True)

                elif pkg == 'udev':
                    udev_rules_dir = os.path.join(rootfs_dir, 'etc/udev/rules.d')
                    os.makedirs(udev_rules_dir, exist_ok=True)

                # Add more package-specific fixes here
                # elif pkg == 'your-package':
                #     # Your package-specific fixes
                #     pass

        # Clean up environment
        for env_var in ['DEBIAN_FRONTEND', 'SYSTEMCTL_SKIP_REDIRECT', 'SYSTEMD_IGNORE_CHROOT', 'DPKG_MAINTSCRIPT_PACKAGE_REFCOUNT']:
            if env_var in os.environ:
                del os.environ[env_var]

        bb.note("=== READONLY ROOTFS HACK: Configuration complete ===")
}

# Hook into rootfs creation
do_rootfs[prefuncs] += "do_rootfs_readonly_hack"
do_rootfs[postfuncs] += "do_rootfs_readonly_restore"
