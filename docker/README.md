# Build docker
docker build -t midilab/build-yocto .

# Run docker
Inside your build directory on host machine:
$ docker run -ti -v $(pwd):/home/build/yocto/ midilab/build-yocto

# submodules

git checkout -t origin/kirkstone

# build

source oe-init-build-env
bitbake core-image-base -n

# decompress image

bzip2 -d -f tmp/deploy/images/raspberrypi3/core-image-base-raspberrypi3-20230227105811.rootfs.wic.bz2

# write to sdcard

sudo dd bs=4M if=core-image-base-raspberrypi3-20230227105811.rootfs.wic of=/dev/sdb status=progress conv=fsync 
