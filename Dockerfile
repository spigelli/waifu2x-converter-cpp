FROM nvidia/cuda:11.1-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive

LABEL maintainer="Isaac Spiegel"

WORKDIR /

RUN set -ex \
    && apt-get update

RUN set -ex \
    && apt-get install -y --no-install-recommends \
      g++ \
      cmake \
      git \
      ca-certificates \
      beignet-opencl-icd \
      mesa-opencl-icd \
      ocl-icd-opencl-dev \
      libopencv-dev

RUN set -ex \
    && apt-get install -y --no-install-recommends \
      build-essential

RUN set -ex \
    && apt-get install -y \
      ocl-icd-opencl-dev

RUN set -ex \
    && apt-get update \
    && apt-get install -y software-properties-common

RUN set -ex \
    && add-apt-repository universe \
    && add-apt-repository multiverse \
    && apt-get update \ 
    && apt-get install -y --no-install-recommends \
      beignet-opencl-icd \
      mesa-opencl-icd \
      ocl-icd-libopencl1 \
      libopencv-core3.2 \
      libopencv-imgcodecs3.2 \
      ocl-icd-opencl-dev \
    && rm -rf /var/lib/apt/lists/*

RUN set -ex \
    && mkdir -p /usr/src \
    && cd /usr/src \
    && git clone https://github.com/spigelli/waifu2x-converter-cpp.git \
    && cd waifu2x-converter-cpp \
    && mkdir out \
    && cd out \
    && cmake .. \
    && make -j$(nproc) \
    && make install \
    && cd / \
    && rm -fr /usr/src/waifu2x-converter-cpp

RUN set -ex \
    && apt install -y ocl-icd-opencl-dev

# Minimal command line test.
RUN set -ex \
    && ldconfig \
    && waifu2x-converter-cpp -h

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
