# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /opt
RUN mkdir /opt/output/
ADD ./release/ /opt/release/
RUN chisel cut --release /opt/release/ --root /opt/output/ base-files.static tzdata.static

FROM public.ecr.aws/lts/ubuntu:22.04 AS source
WORKDIR /tmp
RUN apt-get update && apt-get install -y git
RUN git clone https://github.com/go-training/helloworld.git

FROM golang:1.17 as builder
WORKDIR /go/src/app
COPY --from=source ["/tmp/helloworld", "/go/src/app"]
RUN go mod init
RUN go build -o /go/bin/app

FROM scratch
COPY --from=installer ["/opt/output", "/"]
COPY --from=builder /go/bin/app /
CMD ["/app"]
