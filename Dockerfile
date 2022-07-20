FROM arm64v8/debian:9

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        curl \
        wget \
        mount \
        psmisc \
        dpkg \
        apt \
        lsb-release \
        sudo \
        gnupg \
        apt-transport-https \
        ca-certificates \
        dirmngr \
        mdadm \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get -y --no-install-recommends install systemd \
    && find /etc/systemd/system \
        /lib/systemd/system \
        -path '*.wants/*' \
        -not -name '*journald*' \
        -not -name '*systemd-tmpfiles*' \
        -not -name '*systemd-user-sessions*' \
        -exec rm \{} \; \
    && rm -rf /var/lib/apt/lists/*
STOPSIGNAL SIGKILL

RUN apt-get update \
    && apt-get -y --no-install-recommends install postgresql \
    && sed -i 's/peer/trust/g' /etc/postgresql/9.6/main/pg_hba.conf \
    && sudo apt-get clean \
    && sudo apt-get autoclean \
    && sudo apt-get purge \
    && sudo apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

COPY tempdir/preserve/*.deb src/postgresql.sh /
COPY tempdir/preserve/version /usr/lib/version

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y --no-install-recommends install /ubnt-archive-keyring_*_arm64.deb \
    && echo 'deb https://apt.artifacts.ui.com stretch main release' > /etc/apt/sources.list.d/ubiquiti.list \
    && chmod 666 /etc/apt/sources.list.d/ubiquiti.list \
    && apt-get update \
    && apt-get -y --no-install-recommends install /*.deb node12 \
    && rm -f /*.deb \
    && rm -rf /var/lib/apt/lists/* \
    && echo "CLUSTER_PORT=5432" >> /etc/default/postgresql/9.6-main \
    && /postgresql.sh \
    && rm /postgresql.sh \
    && echo "exit 0" > /usr/sbin/policy-rc.d \
    && sed -i 's/redirectHostname: unifi//' /usr/share/unifi-core/app/config/config.yaml \
    && sed -i 's|echo "$1" > /etc/hostname|#echo "$1" > /etc/hostname|g' /sbin/ubnt-systool \
    && sed -i 's|echo "$1" > /proc/sys/kernel/hostname|#echo "$1" > /proc/sys/kernel/hostname|g' /sbin/ubnt-systool \
    && echo "unifi-protect ALL=SETENV: NOPASSWD:$(grep 'node/v12' /usr/bin/node12 | awk '{ print $4 }')" > /etc/sudoers.d/unifi-protect-node12 \
    && sed -i "s|WatchdogSec=120|WatchdogSec=480|g " /lib/systemd/system/unifi-protect.service

COPY src/ubnt-tools /sbin/ubnt-tools
COPY src/ustorage /sbin/ustorage
COPY src/ubntnas /sbin/ubntnas

VOLUME ["/srv", "/data"]

CMD ["/lib/systemd/systemd"]
