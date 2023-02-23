# Build docker image

docker build -t midilab/archlinuxarm-img-builder . 

# Run docker 

docker run -it --rm -v /dev:/dev --privileged -v $(pwd)/build:/var/img-builder/build -e DEVICE=odroid_xu3 midilab/archlinuxarm-img-builder:latest

# Dependencies

If you're going to use docker the host needs qemu-user-static-binfmt installed. Make sure the FLAGS for arm is set to POCF

pacman -S qemu-user-static-binfmt

cat /proc/sys/fs/binfmt_misc/qemu-arm
enabled
interpreter /usr/libexec/qemu-binfmt/arm-binfmt-P
flags: POCF
offset 0
magic 7f454c4601010100000000000000000002002800
mask ffffffffffffff00fffffffffffffffffeffffff

