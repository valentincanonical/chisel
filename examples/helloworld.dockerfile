# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /staging
RUN [ "chisel", "cut", "--release", "ubuntu-22.04", \
    "--root", "/staging/", "libc6_libs" ]

FROM public.ecr.aws/lts/ubuntu:22.04 AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y gcc
RUN echo 'main(){printf("hello, world\\n");}' > hello.c
RUN gcc -w hello.c -o ./hello-world

FROM scratch
COPY --from=installer [ "/staging/", "/" ]
COPY --from=builder /app/hello-world /
CMD [ "/hello-world" ]

# docker run --rm -it $(docker build . -q -f helloworld.dockerfile)