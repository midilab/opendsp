# build docker image

docker build -t midilab/archlinuxarm-img-builder . 

# run docker 

docker run -it --rm -v /dev:/dev --privileged -v $(pwd)/build:/var/img-builder/build -e DEVICE=odroid_xu3 midilab/archlinuxarm-img-builder:latest


