# Enable necessary graphics support
MACHINE_FEATURES += "intel-graphics"

# Install GRUB bootloader and xf86 drivers for Intel GPU
IMAGE_INSTALL += "grub-efi"

# Specify the WKS file for the image layout
WKS_FILE = "intel-corei7-64.wks"

DEPENDS += "virtual/kernel grub-efi-native"

EFI_PROVIDER = "grub-efi"
GRUB_TARGET = "x86_64-efi"

#do_opendsp_config() {
#    # Configuration specific to Intel Core i7-64
#}
#
#ROOTFS_POSTPROCESS_COMMAND += "do_opendsp_config; "
