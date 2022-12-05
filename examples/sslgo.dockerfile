ARG UBUNTU_RELEASE=22.04

# first, build the "chisel" image with ../Dockerfile
# docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04

FROM chisel:${UBUNTU_RELEASE} as installer
WORKDIR /staging
RUN [ "chisel", "cut", "--release", "ubuntu-22.04", \
    "--root", "/staging/", "libc6_libs", "ca-certificates_data" ]

FROM public.ecr.aws/lts/ubuntu:${UBUNTU_RELEASE} as builder
RUN apt-get update && apt-get install -y golang
WORKDIR /go/src/app
ADD ./src/https.go /go/src/app
RUN go build https.go

FROM scratch
COPY --from=installer [ "/staging/", "/" ]
COPY --from=builder [ "/go/src/app/https", "/" ]
CMD [ "/https" ]

# docker run --rm -it $(docker build . -q -f sslgo.dockerfile)