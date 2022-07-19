#!/bin/bash
set -e

# Source our common vars
scripts_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${scripts_path}/vars.sh

debug_msg "Running 01-extract-files.sh"

# Setup dump dir
if [ ! -d ${FIRMWARE_DUMP_DIR} ]; then
    mkdir ${FIRMWARE_DUMP_DIR}
fi

# Build our builder docker image
debug_msg "Launching the dump script via docker..."
docker run -it -v "${DOCKERPROTECT_DIR}:/repo:Z" "${BUILDER_IMAGE}" /repo/scripts/docker/dump-firmware.sh

debug_msg "Finished 01-extract-files.sh"
