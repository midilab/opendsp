require ${BPN}.inc

DEPENDS = "gtk+ libsndfile1"

EXTRA_OECONF = "--libdir=${libdir}"

FILES:${PN} += " \
    ${datadir} \
"
