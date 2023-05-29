#!/bin/bash

function nmap_recon() {
    local TARGET=$1
    docker run -it --rm autorecon_nmap ${TARGET}
}

while [ $# -gt 0 ]; do
    case $1 in
        -t|--target)
            TARGET=$2
            shift
        ;;
    esac
    shift
done

nmap_recon "$TARGET"