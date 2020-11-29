FROM nvidia/cuda:11.1-devel-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive

#FROM debian:buster-slim as builder
#COPY --from=builder /usr/local/ /usr/local/

LABEL maintainer="Isaac Spiegel"

WORKDIR /

# apt-get install
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
    # && echo "deb http://ftp.de.debian.org/debian sid main" | tee -a /etc/apt/sources.list \
    # && add-apt-repository "deb http://ftp.de.debian.org/debian sid main" \
    # && apt-get update --allow-unauthenticated \ 
    # && apt install -y libopencv-imgcodecs3.2 -o APT::Immediate-Configure=0 \
    # && apt install -y libcharls2

# RUN set -ex \
#     && find / -name "libopencv_imgproc*" \
#     && ln /usr/share/lintian/overrides/libopencv-imgcodecs4.2  /usr/share/lintian/overrides/libopencv-imgcodecs3.2 \
#     && ln /usr/lib/x86_64-linux-gnu/libopencv_core.so.4.2  /usr/lib/x86_64-linux-gnu/libopencv_core.so.3.2 \
#     && ln /usr/lib/x86_64-linux-gnu/libopencv_imgcodecs.so.4.2  /usr/lib/x86_64-linux-gnu/libopencv_imgcodecs.so.3.2 \
#     && ln /usr/lib/x86_64-linux-gnu/libopencv_imgproc.so.4.2  /usr/lib/x86_64-linux-gnu/libopencv_imgproc.so.3.2
    # && ln /usr/share/doc/libopencv-imgcodecs4.2  /usr/share/doc/libopencv-imgcodecs3.2

RUN set -ex \
    && ldconfig \
    && waifu2x-converter-cpp -h

COPY docker-entrypoint.sh /usr/local/bin
ENTRYPOINT ["docker-entrypoint.sh"]
