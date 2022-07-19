#!/bin/bash
set -e

# Source our common vars
scripts_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
. ${scripts_path}/vars.sh

# Did we already extract?
if [ -d "${FIRMWARE_DUMP_DIR}/extracted" ]; then
    error_msg "Firmware was already dumped! Exiting and continuing..."
    exit 0
else
    mkdir "${FIRMWARE_DUMP_DIR}/extracted"
fi

# copy firmware to it's extract location
cp "${DOWNLOAD_DIR}/UNVR-firmware.bin" "${FIRMWARE_DUMP_DIR}/UNVR-firmware.bin"

# CD up...
pushd "${FIRMWARE_DUMP_DIR}" > /dev/null

# Do the extraction of the .bin if required
if [ ! -d "${FIRMWARE_DUMP_DIR}/_UNVR-firmware.bin.extracted/squashfs-root" ]; then
    debug_msg "Extracting firmware..."
    binwalk -y "ubiquiti" -y "squashfs" -e ./UNVR-firmware.bin
fi

# Now extract the packages we want
debug_msg "Repackaging Debs..."
pushd "${FIRMWARE_DUMP_DIR}/extracted" > /dev/null
while read pkg; do
  dpkg-repack -d "-Zxz" --root="${FIRMWARE_DUMP_DIR}/_UNVR-firmware.bin.extracted/squashfs-root/" --arch=arm64 ${pkg}
done < ${scripts_path}/docker/packages.txt

# Also copy our version file
cp "${FIRMWARE_DUMP_DIR}/_UNVR-firmware.bin.extracted/squashfs-root/usr/lib/version" "${FIRMWARE_DUMP_DIR}/extracted/version"

# Move our files to the preserve dir
if [ ! -d "${PRESERVE_DIR}" ]; then
    mkdir "${PRESERVE_DIR}" 
fi 
cp ${FIRMWARE_DUMP_DIR}/extracted/* "${PRESERVE_DIR}" 

debug_msg "Extraction Complete!"