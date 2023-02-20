#!/usr/bin/env bash

# defaults
arch="${ARCHITECTURE}"
device="${DEVICE}"
customization=''
image=''

# make sure to setup your BUILDER_PATH enviroment var before run me!
export BUILDER_PATH
export ROOT_MOUNT
export RELEASE_DOWNLOAD_URL=http://os.archlinuxarm.org/os/

select_arch() {
    echo ""
    PS3="Select the arch to use: "

    cd "${BUILDER_PATH}/platforms/"
    declare -a arrArchs
    for dir in *
    do
        arrArchs+=($dir)
    done

    select target in ${arrArchs[@]} quit;
    do
        case ${target} in
            quit)
                exit 0
                ;;
            *)
                arch=${target}
                break
                ;;
        esac
    done
}

select_device() {
    echo ""
    PS3="Select the device to use: "

    cd "${BUILDER_PATH}/platforms/${arch}/"
    declare -a arrDevices
    for file in *
    do
        arrDevices+=(${file%.*})
    done

    select target in ${arrDevices[@]} quit;
    do
        case ${target} in
            quit)
                exit 0
                break
                ;;
            *)
                device=${target}
                break
                ;;
        esac
    done
}

select_customization() {
    echo ""
    PS3="Any customization to apply?: "

    cd "${BUILDER_PATH}/customizations/"
    declare -a arrCustom
    for dir in *
    do
        arrCustom+=($dir)
    done

    select target in ${arrCustom[@]} quit;
    do
        case ${target} in
            quit)
                exit 0
                break
                ;;
            *)
                customization=${target}
                break
                ;;
        esac
    done
}

select_image() {
    echo ""
    PS3="Select the image to emulate: "

    cd ${BUILDER_PATH}/build/
    declare -a arrImgs
    for file in *.img
    do
        arrImgs+=($file)
    done

    select target in ${arrImgs[@]} quit;
    do
        case ${target} in
            quit)
                exit 0
                break
                ;;
            *)
                image=${target}
                break
                ;;
        esac
    done

    # get arch and device based on image name
    # layout: CUSTOMIZATION-ARCH-DEVICE-date.img
    while IFS='-' read -ra DATA; do
        for i in "${!DATA[@]}"; do
            if [ $i -eq 0 ]; then
                customization=${DATA[$i]}
            elif [ $i -eq 1 ]; then
                arch=${DATA[$i]}
            elif [ $i -eq 2 ]; then
                device=${DATA[$i]}
            fi
        done
    done <<< "${image}"
}

echo "
 ██████╗ ██████╗ ███████╗███╗   ██╗██████╗ ███████╗██████╗ 
██╔═══██╗██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔════╝██╔══██╗
██║   ██║██████╔╝█████╗  ██╔██╗ ██║██║  ██║███████╗██████╔╝
██║   ██║██╔═══╝ ██╔══╝  ██║╚██╗██║██║  ██║╚════██║██╔═══╝ 
╚██████╔╝██║     ███████╗██║ ╚████║██████╔╝███████║██║     
 ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝     "
echo "Archlinux ARM sdcard image builder"
echo ""

PS3="What do you want to do?: "
select opt in create emulate quit; do

  case ${opt} in
    create)
      select_arch
      select_device
      select_customization
      ROOT_MOUNT=${customization}-${arch}-${device}-$(date "+%Y-%m-%d-%H_%M")
      ${BUILDER_PATH}/manage_img.sh create ${arch} ${device} ${customization}
      ${BUILDER_PATH}/manage_img.sh umount ${arch} ${device} ${image}
      break
      ;;
    emulate)
      select_image
      ROOT_MOUNT=${customization}-${arch}-${device}-$(date "+%Y-%m-%d-%H_%M")
      ${BUILDER_PATH}/manage_img.sh emulate ${arch} ${device} ${image}
      break
      ;;
    quit)
      break
      ;;
    *) 
      echo "Invalid option ${REPLY}"
      ;;
  esac
done