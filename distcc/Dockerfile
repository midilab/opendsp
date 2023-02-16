FROM archlinux:base-devel

ENV LANG=en_US.UTF-8

# setup distcc
RUN pacman -Syu --noconfirm && pacman -S distcc wget --noconfirm

# toolchain for armv7h
RUN ["/usr/bin/mkdir", "/var/distcc"]
ADD ["distcc-init-armv7h.sh", "/usr/bin/"]
ADD ["https://archlinuxarm.org/builder/xtools/x-tools7h.tar.xz", "/tmp/"]
RUN ["/usr/bin/tar", "-vxJf", "/tmp/x-tools7h.tar.xz", "-C", "/var/distcc"]
EXPOSE 3632/tcp
ENTRYPOINT ["/usr/bin/distcc-init-armv7h.sh"]
