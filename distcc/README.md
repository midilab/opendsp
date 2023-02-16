# build docker image

docker build -t midilab/archlinuxarm-distcc-v7 . 

# run docker 

docker run -d -p 127.0.0.1:3632:3632 midilab/archlinuxarm-distcc-v7:latest


