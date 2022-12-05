ARG UBUNTU_RELEASE=22.04

FROM public.ecr.aws/lts/ubuntu:${UBUNTU_RELEASE} AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y gcc
RUN echo 'main(){printf("hello, world\\n");}' > hello.c
RUN gcc -w hello.c -o ./hello-world

FROM chiselled-base:${UBUNTU_RELEASE}
COPY --from=builder /app/hello-world /
CMD [ "/hello-world" ]

# docker run --rm -it $(docker build . -q -f example.dockerfile)
