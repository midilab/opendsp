# Enable necessary graphics support
MACHINE_FEATURES += " intel-graphics opengl"

# Install GRUB bootloader and xf86 drivers for Intel GPU
IMAGE_INSTALL += " grub-efi"

# X11 support for generic Intel
# xf86-video-amdgpu: not avaliable for kirkstone
IMAGE_INSTALL += " \
    xf86-video-ast \
    xf86-video-intel \
    xf86-video-vesa \
    xf86-video-vmware \
    xf86-video-ati \
    xf86-video-nouveau \
"

# Specify the WKS file for the image layout
WKS_FILE = "intel-corei7-64.wks"

DEPENDS += " virtual/kernel grub-efi-native"

# for live os and self-install
EFI_PROVIDER = "grub-efi"
GRUB_TARGET = "x86_64-efi"
GRUB_TIMEOUT = "0"

IMAGE_FSTYPES:append = " ext4"
IMAGE_TYPEDEP_wic = "ext4"

INITRD_IMAGE_LIVE="core-image-minimal-initramfs"
do_image_wic[depends] += "${INITRD_IMAGE_LIVE}:do_image_complete"
do_image_wic[depends] += "${IMAGE_BASENAME}:do_image_ext4"
do_rootfs[depends] += "virtual/kernel:do_deploy"

#do_opendsp_config() {
#    # Configuration specific to Intel Core i7-64
#}
#
#ROOTFS_POSTPROCESS_COMMAND += "do_opendsp_config; "
