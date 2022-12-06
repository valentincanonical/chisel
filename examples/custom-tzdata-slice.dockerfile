
FROM public.ecr.aws/lts/ubuntu:22.04 AS installer
# Starts a new build stage called "installer" from the specified image

WORKDIR /staging

# Copying the Chisel binary to our current build image
COPY --from=chisel:22.04 /usr/bin/chisel /usr/bin/chisel
# You first need to build the "chisel:22.04" image using the "../Dockerfile" file with the argument "UBUNTU_RELEASE=22.04"
# ``` docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04 ```

# Check the https://github.com/cjdcordeiro/chisel-releases/tree/ubuntu-22.04_2 for the TZdata slice definition!
RUN apt-get update && apt-get install -y git

RUN git clone -b ubuntu-22.04_2 https://github.com/cjdcordeiro/chisel-releases /opt/chisel-releases
# Downloads the customised Package slices definition from our forked git repository

# Using this alternative Chisel-releases database, let's chisel Ubuntu including TZdata
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
# Copies the files from the chiselled Ubuntu ("installer") to the root directory ("/") of the new from-scratch image

# USAGE:
# This provides the usage instructions for building the "chisel-tzdata-base:22.04" image from this Dockerfile:
# 1. Build the "chisel:22.04" image using the "../Dockerfile" file with the argument "UBUNTU_RELEASE=22.04"
#    ``` docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04 ```
# 2. Build the "chisel-tzdata-base:22.04" image using the current Dockerfile
#    ``` docker build . -f custom-tzdata-slice.dockerfile -t chisel-tzdata-base:22.04 ```
#
#  Note that this iimage is the 1:1 equivalent of the Google Distroless "base", built with Ubuntu content!
