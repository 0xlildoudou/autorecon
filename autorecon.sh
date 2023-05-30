#!/bin/bash

function cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    [[ -z ${TEMP_FOLDER} ]] || rm -rf ${TEMP_FOLDER}
}

function nmap_recon() {
    local TARGET=$1
    echo "Starting NMAP..."
    NMAP=$(docker run -it --rm -v ${TEMP_FOLDER}:/opt --name autorecon_nmap autorecon_nmap ${TARGET} -oX /opt/nmap_out.txt)
}

function dirb_recon() {
    local TARGET=$1
    local PORT=$2
    echo "Starting dirb..."
    if [[ ${PORT} == "80" ]]; then
        mkfifo ${TEMP_FOLDER}/dirb_80.txt
        DIRB=$(docker run -it -d --rm -v ${TEMP_FOLDER}:/opt --name autorecon_dirb autorecon_dirb "http://${TARGET}/ -S 2>/opt/dirb_80.txt")
    elif [[ ${PORT} == "443" ]]; then
        mkfifo ${TEMP_FOLDER}/dirb_443.txt
        DIRB=$(docker run -it -d --rm -v ${TEMP_FOLDER}:/opt --name autorecon_dirb autorecon_dirb https://${TARGET})
    fi
    echo ${DIRB}
}

trap cleanup SIGINT SIGTERM ERR EXIT

while [ $# -gt 0 ]; do
    case $1 in
        -t|--target)
            TARGET=$2
            shift
        ;;
    esac
    shift
done

TEMP_FOLDER=$(mktemp -d)

nmap_recon "$TARGET"

OPEN_PORT=($(awk -F 'portid="' 'match($0, /portid="([0-9]+)"/, m) {print m[1]}' ${TEMP_FOLDER}/nmap_out.txt))
echo "port open : ${OPEN_PORT[@]}"

for port in ${!OPEN_PORT[@]}; do
    if [[ ${OPEN_PORT[$port]} == "80" ]] || [[ ${OPEN_PORT[$port]} == "443" ]]; then
        dirb_recon "${TARGET}" "${OPEN_PORT[$port]}"
    fi 
done

while [[ *"$(docker ps -a)"* ==  *"autorecon_"* ]]; do
    sleep 3
done