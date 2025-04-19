# Auto package audio plugins

inherit audio-plugin-common

PACKAGES =+ "${PN_DSSI} ${PN_LADSPA} ${PN_LV2} ${PN_VST} ${PN_VST3}"

FILES:${PN_DSSI} += "${libdir}/dssi"
FILES:${PN_LADSPA} += "${libdir}/ladspa"
FILES:${PN_LV2} += "${libdir}/lv2"
FILES:${PN_VST} += "${libdir}/vst"
FILES:${PN_VST3} += "${libdir}/vst3"
