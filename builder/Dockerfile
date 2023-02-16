FROM archlinux:base

# arguments
ENV DEVICE='raspberry_pi2'

ENV LANG=en_US.UTF-8

# setup distcc
RUN pacman -Syu --noconfirm && pacman -S unzip multipath-tools parted sshpass zip dosfstools qemu-user-static-binfmt arch-install-scripts wget --noconfirm

# toolchain for armv7h
RUN ["/usr/bin/mkdir", "/var/img-builder"]
ADD ["manage_img.sh", "/var/img-builder/"]
ADD ["platforms/", "/var/img-builder/platforms/"]
ADD ["builder-init.sh", "/var/img-builder"]
ENTRYPOINT ["/var/img-builder/builder-init.sh"]
