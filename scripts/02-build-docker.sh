#!/bin/bash
set -e

# Source our common vars
scripts_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. ${scripts_path}/vars.sh

debug_msg "Running 02-build-docker.sh"


# Build our builder docker image
debug_msg "Building unifi-protect-arm64:latest..."
docker build --platform linux/arm64/v8 -t unifi-protect-arm64:latest -f ${DOCKERPROTECT_DIR}/Dockerfile ${DOCKERPROTECT_DIR}

debug_msg "Finished 02-build-docker.sh"
