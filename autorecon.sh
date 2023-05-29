#!/bin/bash

function cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    [[ -z ${TEMP_FOLDER} ]] || rm -rf ${TEMP_FOLDER}
}

function nmap_recon() {
    local TARGET=$1
    echo "Starting NMAP..."
    NMAP=$(docker run -it --rm -v ${TEMP_FOLDER}:/opt autorecon_nmap ${TARGET} -oG /opt/nmap_out.txt)
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
cat ${TEMP_FOLDER}/nmap_out.txt