FROM archlinux:base

ENV LANG=en_US.UTF-8

# setup qemu armv7h environment
RUN pacman -Syu --noconfirm && pacman -S unzip multipath-tools parted sshpass zip dosfstools qemu-user-static-binfmt arch-install-scripts wget --noconfirm

# setup opendsp builder
RUN ["/usr/bin/mkdir", "-p", "/var/img-builder/build/"]
ADD ["manage_img.sh", "/var/img-builder/"]
ADD ["platforms/", "/var/img-builder/platforms/"]
ADD ["customizations/", "/var/img-builder/customizations/"]
ADD ["builder-init.sh", "/var/img-builder"]
ENTRYPOINT ["/var/img-builder/builder-init.sh"]
