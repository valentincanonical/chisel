ARG UBUNTU_RELEASE=22.04

# first, build the "chisel" image with ../Dockerfile
# docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04

FROM chisel:${UBUNTU_RELEASE} as installer
WORKDIR /staging
RUN [ "chisel", "cut", "--release", "ubuntu-22.04", \
    "--root", "/staging/", "libc6_libs" ]

FROM public.ecr.aws/lts/ubuntu:${UBUNTU_RELEASE} AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y gcc
RUN echo 'main(){printf("hello, world\\n");}' > hello.c
RUN gcc -w hello.c -o ./hello-world

FROM scratch
COPY --from=installer [ "/staging/", "/" ]
COPY --from=builder /app/hello-world /
CMD [ "/hello-world" ]

# docker run --rm -it $(docker build . -q -f helloworld.dockerfile)