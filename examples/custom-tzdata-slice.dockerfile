# first, build the "chisel" image with ../Dockerfile:
# docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04

FROM public.ecr.aws/lts/ubuntu:22.04 AS installer
WORKDIR /staging

# Copying the Chisel binary to our current build image
COPY --from=chisel:22.04 /usr/bin/chisel /usr/bin/chisel

# check the https://github.com/cjdcordeiro/chisel-releases/tree/ubuntu-22.04_2 for the TZdata slice definition!
RUN apt-get update && apt-get install -y git
RUN git clone -b ubuntu-22.04_2 https://github.com/cjdcordeiro/chisel-releases /opt/chisel-releases

# Using this alternative Chisel-releases database, let's chisel Ubuntu with TZdata
RUN chisel cut --release /opt/chisel-releases --root /staging \
    base-files_base \
    base-files_release-info \
    tzdata_zoneinfo \
    ca-certificates_data \
    libc-bin_nsswitch \
    libc6_libs \
    libssl3_libs \
    openssl_config

FROM scratch
COPY --from=installer [ "/staging/", "/" ]

# USAGE:
# docker build . -f custom-tzdata-slice.dockerfile -t chisel-tzdata-base:22.04
#
# Note this iimage is the 1:1 equivalent of the Google Distroless "base" built with Ubuntu content!