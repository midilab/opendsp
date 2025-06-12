SUMMARY = "User-friendly, powerful music visualization / VJing tool"
DESCRIPTION = "Le Biniou is a free and open source sound visualization and VJing software. \
It works with music, voice, ambient sounds, whatever acoustic source you choose. \
When you run Le Biniou it gives an evolutionary rendering of the sound you are playing."
HOMEPAGE = "https://gitlab.com/lebiniou/lebiniou"
SECTION = "multimedia"
LICENSE = "GPL-2.0-or-later"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

inherit autotools pkgconfig features_check

REQUIRED_DISTRO_FEATURES = "opengl"

SRC_URI = "git://gitlab.com/lebiniou/lebiniou.git;branch=master;protocol=https"
SRCREV = "9243b251b4ee03f7f8035669383c3ea4faf7aa5a"
S = "${WORKDIR}/git"
PV = "3.67.0"

DEPENDS = " \
    alsa-lib \
    cairo \
    fftw \
    ffmpeg \
    libsdl2 \
    glib-2.0 \
    gstreamer1.0 \
    gstreamer1.0-plugins-base \
    gtk+3 \
    jack \
    libpng \
    libxml2 \
    jansson \
    imagemagick \
    liborcania \
    libyder \
    libufius \
    mesa \
    pango \
    virtual/libgl \
    virtual/egl \
    perl-native \
"

PACKAGECONFIG ??= "jackaudio sndfile opengl"
PACKAGECONFIG[jackaudio] = "--enable-jackaudio,--disable-jackaudio,jack"
PACKAGECONFIG[pulseaudio] = "--enable-pulseaudio,--disable-pulseaudio,pulseaudio"
PACKAGECONFIG[alsa] = "--enable-alsa,--disable-alsa,alsa"
PACKAGECONFIG[esd] = "--enable-esd,--disable-esd,esd"
PACKAGECONFIG[sndfile] = "--enable-sndfile,--disable-sndfile,libsndfile1"
PACKAGECONFIG[twip] = "--enable-twip,--disable-twip,twip"
PACKAGECONFIG[caca] = "--enable-caca,--disable-caca,caca"
PACKAGECONFIG[opengl] = "--enable-opengl,--disable-opengl,mesa"
LICENSE_FLAGS_ACCEPTED_pn-lebiniou = "commercial"

do_configure:prepend() {
    ( cd ${S} && ./bootstrap )
}

do_compile:prepend() {
    sed -i \
        -e 's/cp -f commands.h.head/cp -f $(srcdir)\/commands.h.head/g' \
        -e 's/cat commands.h.tail/cat $(srcdir)\/commands.h.tail/g' \
        -e 's/commands.c.in/$(srcdir)\/commands.c.in/g' \
        -e 's/commands_enum.awk/$(srcdir)\/commands_enum.awk/g' \
        -e 's/gen.awk/$(srcdir)\/gen.awk/g' \
        -e 's/bulfius_get_commands.awk/$(srcdir)\/bulfius_get_commands.awk/g' \
        -e 's/bulfius_str2command.awk/$(srcdir)\/bulfius_str2command.awk/g' \
        -e 's/bulfius_command2str.awk/$(srcdir)\/bulfius_command2str.awk/g' \
        ${S}/src/Makefile.am

    # port all xpthread_mutex_* to pthread_mutex_lock in all .c files in src/
    find ${S}/src -type f -name '*.c' -exec \
        sed -i \
            -e 's/xpthread_mutex_lock/pthread_mutex_lock/g' \
            -e 's/xpthread_mutex_unlock/pthread_mutex_unlock/g' \
            -e 's/xpthread_mutex_destroy/pthread_mutex_destroy/g' \
            -e 's/xpthread_mutex_init/pthread_mutex_init/g' \
        {} +
}

do_install:append() {
    find ${D} -name "*.la" -delete
}

FILES:${PN} += " \
    ${datadir}/lebiniou \
    ${datadir}/applications \
    ${datadir}/pixmaps \
    ${datadir}/locale \
"

RDEPENDS:${PN} += " \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
"

PACKAGES =+ "${PN}-data"
SUMMARY:${PN}-data = "Data files for lebiniou"
FILES:${PN}-data = "${datadir}/lebiniou"
RDEPENDS:${PN} += "${PN}-data"
