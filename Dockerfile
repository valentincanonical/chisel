ARG UBUNTU_RELEASE=22.04

# STAGE 1: Build Chisel using the Golang SDK
FROM golang:1.18 as builder
RUN mkdir /build
ADD . /build/
WORKDIR /build/
RUN cd cmd && ./mkversion.sh
RUN go build -o $(pwd) $(pwd)/cmd/chisel

# STAGE 2: Create a Chiselled Ubuntu environment for Chisel to run
FROM public.ecr.aws/lts/ubuntu:${UBUNTU_RELEASE} as installer
RUN apt-get update && apt-get install -y ca-certificates
COPY --from=builder /build/chisel /usr/bin/
WORKDIR /rootfs
RUN chisel cut --root /rootfs libc6_libs ca-certificates_data base-files_release-info

# STAGE 3: Assemble the Chisel binary + its chiselled dependencies
FROM scratch
COPY --from=installer ["/rootfs", "/"]
COPY --from=builder /build/chisel /usr/bin/
ENTRYPOINT [ "/usr/bin/chisel" ]
CMD [ "--help" ]

# *** BUILD (run from the host, not from the DevContainer) ***
# docker build . -t chisel:latest
#
# *** USAGE ***
# mkdir chiselled
# docker run -v $(pwd)/chiselled:/opt/output --rm chisel cut --release ubuntu-22.04 --root /opt/output/ libc6_libs ca-certificates_data
# ls -la ./chiselled