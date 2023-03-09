MACHINE_FEATURES:remove = "bluetooth"
MACHINE_FEATURES += "vc4graphics"

# install xf86 drivers for vc4 broadcom GPU
IMAGE_INSTALL += "xf86-video-fbdev"

WKS_FILE = "raspberrypi.wks"

do_opendsp_config() {

    CONFIG=${DEPLOY_DIR_IMAGE}/${BOOTFILES_DIR_NAME}/config.txt

	echo "dtparam=audio=on" >> ${CONFIG}
	echo "disable_audio_dither=1" >> ${CONFIG}
	echo "audio_pwm_mode=2" >> ${CONFIG}

	echo "# most common sound cards overlay drivers" >> ${CONFIG}
	echo "#dtoverlay=hifiberry-dacplus" >> ${CONFIG}
	echo "#dtoverlay=hifiberry-dac" >> ${CONFIG}
	echo "#dtoverlay=hifiberry-digi" >> ${CONFIG}
	echo "#dtoverlay=hifiberry-amp" >> ${CONFIG}
	echo "#dtoverlay=audioinjector-wm8731-audio" >> ${CONFIG}
	echo "#dtoverlay=iqaudio-dac" >> ${CONFIG}
	echo "#dtoverlay=iqaudio-dacplus" >> ${CONFIG}
	echo "#dtoverlay=iqaudio-digi-wm8804-audio" >> ${CONFIG}
	echo "#dtoverlay=pisound" >> ${CONFIG}
	echo "#dtoverlay=justboom-dac" >> ${CONFIG}
	echo "#dtoverlay=justboom-digi" >> ${CONFIG}
	echo "#dtoverlay=iqaudio-dac" >> ${CONFIG}

	echo "dtoverlay=i2s-mmap" >> ${CONFIG}

	echo "enable_uart=1" >> ${CONFIG}
	echo "dtoverlay=pi3-miniuart-bt" >> ${CONFIG}
	echo "dtoverlay=midi-uart0" >> ${CONFIG}

	echo "hdmi_force_hotplug=1" >> ${CONFIG}
	echo "hdmi_drive=2" >> ${CONFIG}
	echo "hdmi_group=1" >> ${CONFIG}
	echo "hdmi_mode=4" >> ${CONFIG}

	echo "disable_splash=1" >> ${CONFIG}
	echo "avoid_warnings=1" >> ${CONFIG}
	echo "max_usb_current=1" >> ${CONFIG}
}

ROOTFS_POSTPROCESS_COMMAND += "do_opendsp_config; "