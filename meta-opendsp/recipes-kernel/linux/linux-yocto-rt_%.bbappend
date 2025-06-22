FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += "file://full-preempt-nohz.cfg"

# technicly only those options are generic enough
#CONFIG_PREEMPT_RT_FULL
#CONFIG_CPU_FREQ=n
#CONFIG_CPU_IDLE=n
#CONFIG_NO_HZ_FULL=y
#CONFIG_RCU_NOCB_CPU=y
