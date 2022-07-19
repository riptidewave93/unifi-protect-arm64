#!/bin/bash
set -e

# Source our common vars
scripts_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${scripts_path}/vars.sh

debug_msg "Running 00-prebuild-setup.sh"

# Validate our env is setup
if [ ! "${UNVR_FIRMWARE}" ]; then
    error_msg "UNVR_FIRMWARE is unset! Please review README.md"
    exit 1
fi

# Setup temp dir
if [ ! -d ${DOCKERPROTECT_DIR}/tempdir ]; then
    mkdir ${DOCKERPROTECT_DIR}/tempdir
fi

# Setup download dir
if [ ! -d ${DOCKERPROTECT_DIR}/downloads ]; then
    mkdir ${DOCKERPROTECT_DIR}/downloads
fi

# Download and validate our firmware file
if [ ! -f ${DOWNLOAD_DIR}/UNVR-firmware.bin ]; then
    debug_msg "Downloading UNVR Firmware from provided URL..."
    wget ${UNVR_FIRMWARE} -O ${DOWNLOAD_DIR}/UNVR-firmware.bin
fi

# Validate MD5 and bomb out if it's a lie
debug_msg "Validating firmware..."
DLFIRMHASH=$(md5sum "${DOWNLOAD_DIR}/UNVR-firmware.bin" | awk '{print $1}')
if [[ "${DLFIRMHASH}" != "${FIRMWARE_MD5}" ]]; then
    error_msg "Warning, incorrect firmware detected! Please revirew README.md to find what file to provide!"
    rm "${DOWNLOAD_DIR}/UNVR-firmware.bin"
    exit 1
fi

# Build our builder docker image
debug_msg "Building the firmware dump docker image..."
docker build -t ${BUILDER_IMAGE} -f ${DOCKERPROTECT_DIR}/Dockerfile.builder ${DOCKERPROTECT_DIR}

debug_msg "Finished 00-prebuild-setup.sh"
