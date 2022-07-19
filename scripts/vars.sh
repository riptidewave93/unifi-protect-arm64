#!/bin/bash
export DOCKERPROTECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
export DOWNLOAD_DIR=$DOCKERPROTECT_DIR/downloads
export FIRMWARE_DUMP_DIR=$DOCKERPROTECT_DIR/tempdir/firmware
export PRESERVE_DIR=$DOCKERPROTECT_DIR/tempdir/preserve

FIRMWARE_MD5="41ef8bd1c22bb836cad4133e33a69119"
BUILDER_IMAGE="unifi-protect-arm64-builder:latest"

debug_msg () {
    BLU='\033[0;32m'
    NC='\033[0m'
    printf "${BLU}${@}${NC}\n"
}

error_msg () {
    BLU='\033[0;31m'
    NC='\033[0m'
    printf "${BLU}${@}${NC}\n"
}
