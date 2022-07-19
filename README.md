# UniFi Protect ARM64

Run UniFi Protect in Docker on ARM64 hardware. Currently based on UNVR Firmware 2.5.9

## Usage

Note that this repo will never offer a pre-build image, so you must always manually build your own Docker image. To do this, please first obtain the update URL for the latest supported build. As of current, this is `e825-UNVR-2.5.9-e726b4b49f9045098d114a7f5c5d2f04.bin`. Once obtained, you can run the following command:

```
UNVR_FIRMWARE=PUTFIRMWAREURLHERE make build
```

Note that ONLY THIS FILE will work! Any other firmware release will fail to validate. Once complete, a local docker image named `unifi-protect-arm64:latest` will be available for use.

To run the container as a daemon:

```
docker run -d --name unifi-protect \
    --cgroupns=host \
    --privileged \
    --tmpfs /run \
    --tmpfs /run/lock \
    --tmpfs /tmp \
    -v /sys/fs/cgroup:/sys/fs/cgroup \
    -v /storage/srv:/srv \
    -v /storage/data:/data \
    -v /storage/persistent:/persistent \
    --network host \
    --restart unless-stopped \
    unifi-protect-arm64:latest
```

Now you can access UniFi Protect at `https://localhost/`. Note that to use newer versions of docker changes are needed to use cgroups v1. Because of this, it is RECOMMENDED to use podman instead as it does not have the same issues Docker does. More details on how to configure docker for cgroups v1 can be found [Here](https://github.com/moby/moby/issues/42275#issuecomment-1115041405)

## Known Issues

### Storage
UniFi Protect needs a lot of storage to record video. Protect will fail to start if there is not at least 100GB disk space available, so make sure to store your Docker volumes on a disk with some space (`/storage` in the above run command).

### Stuck at "Device Updating"
If you are stuck at a popup saying "Device Updating" with a blue loading bar after the initial setup, just run `systemctl restart unifi-core` inside the container or restart the entire container. This happens only the first time after the initial setup.

### Protect keeps restarting
This normally happens if the backing storage is too slow to keep up with Unifi Protect. You can normally fix this by moving to a faster HDD/SSD, or by increasing the watchdog on the unifi-protect service. To do this, exec into the docker pod and then run the following commands:

```
sed -i "s|WatchdogSec=120|WatchdogSec=480|g " /lib/systemd/system/unifi-protect.service
systemctl daemon-reload
systemctl restart unifi-protect.service
```

## Thanks
This repo only exists thanks to the work that was done initially at https://github.com/markdegrootnl/unifi-protect-arm64.

## Disclaimer
This Docker image is not associated with UniFi in any way. We do not distribute any third party software and only use packages that are freely available on the internet. All UniFi software is copyright/owned by Ubiquiti, and will never be redistribued from this repo.