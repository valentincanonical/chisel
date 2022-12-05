# first, build the "chisel" image with ../Dockerfile:
# docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04

FROM chisel:22.04 as installer
WORKDIR /staging
RUN ["chisel", "cut", "--root", "/staging", \
    "base-files_base", \
    "base-files_release-info", \
    "ca-certificates_data", \
    "libc6_libs", \
    "libssl3_libs", \
    "openssl_config" ]

FROM scratch
COPY --from=installer [ "/staging/", "/" ]

# USAGE (run from the host, not from the DevContainer)
# docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04
# docker build . -t chiselled-ssl-base:22.04 -f chiselled-ssl-base.dockerfile

