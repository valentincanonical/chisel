# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /staging
RUN [ "chisel", "cut", "--release", "ubuntu-22.04", \
      "--root", "/staging/", \
      "base-files_base", "ca-certificates_data", "libc6_libs", "openssl_bins" ]

FROM scratch
COPY --from=installer [ "/staging/", "/" ]

# docker build . -t ubuntu-distroless:22.04 -f distroless.dockerfile