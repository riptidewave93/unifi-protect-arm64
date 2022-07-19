FROM ubuntu:22.04

ENV BINWALK_RELEASE="https://github.com/ReFirmLabs/binwalk/archive/refs/tags/v2.3.2.tar.gz"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -yq --no-install-recommends \
    python3 \
    python3-pip \
    dpkg-repack \
    dpkg \
    gzip \
    squashfs-tools \
    wget \
    xzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget ${BINWALK_RELEASE} -O /usr/src/binwalk.tar.gz \
    && tar xzvf /usr/src/binwalk.tar.gz -C /usr/src \
    && rm /usr/src/binwalk.tar.gz \
    && cd /usr/src/binwalk-2.3.2 \
    && python3 setup.py install \ 
    && mkdir /repo