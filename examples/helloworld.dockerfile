# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /opt
RUN mkdir /opt/output/
ADD ./release/ /opt/release/
RUN chisel cut --release /opt/release/ --root /opt/output/ libc6.runtime

FROM public.ecr.aws/lts/ubuntu:22.04 AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y gcc
RUN echo 'main(){printf("hello, world\\n");}' > hello.c
RUN gcc -w hello.c -o ./hello-world

FROM scratch
COPY --from=installer ["/opt/output", "/"]
COPY --from=builder /app/hello-world /
CMD ["/hello-world"]
