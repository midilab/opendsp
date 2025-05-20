#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
#set -e

LOG_TAG="first-boot-setup"

log_info() {
    echo "$LOG_TAG: $1"
}

log_error() {
    echo "$LOG_TAG: ERROR: $1" >&2
}

DEFAULT_PASSWORD="opendspd"

# update all opendsp service/user passwords
changepasswd ${DEFAULT_PASSWORD}

# remount file system for write
sudo mount -o remount,rw / || true
sleep 1

# resize data partion
log_info "Resizing user data partition, this migth take a while, please hold..."
resize_userdata

rm -f "$0"
if [ $? -ne 0 ]; then
    log_error "Warning: Failed to remove the script file $0."
fi

# remove service file too
systemctl disable first-boot-setup
rm -f /etc/systemd/system/first-boot-setup.service

# remount file system read-only
sudo mount -o remount,ro / || true
sleep 1

# reboot to get everything working as expected
reboot
