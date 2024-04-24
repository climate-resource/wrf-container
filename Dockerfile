FROM ubuntu:20.04 as base

MAINTAINER Jared Lewis <jared.lewis@climate-resource.com>

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && \
    apt-get install -y sudo curl build-essential gfortran m4 csh git jq wget aria2 imagemagick libmpich-dev file && \
    rm -rf /var/lib/apt/lists/*

FROM base as build

ARG TARGETPLATFORM
ARG WRF_VERSION=4.5.1
ARG WPS_VERSION=4.5


COPY scripts /opt/wrf/build/scripts/

WORKDIR /opt/wrf

RUN PLATFORM=${TARGETPLATFORM} bash /opt/wrf/build/scripts/install_deps.sh
RUN PLATFORM=${TARGETPLATFORM} WRF_VERSION=${WRF_VERSION} WPS_VERSION=${WPS_VERSION} bash /opt/wrf/build/scripts/build_wrf.sh

ENTRYPOINT ["/bin/bash"]