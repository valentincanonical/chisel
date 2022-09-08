# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /opt
RUN mkdir /opt/output/
ADD ./release/ /opt/release/
RUN chisel cut --release /opt/release/ --root /opt/output/ ca-certificates.static libc6.runtime

FROM public.ecr.aws/lts/ubuntu:22.04 as builder
RUN apt-get update && apt-get install -y golang
WORKDIR /go/src/app
ADD ./src/https.go /go/src/app
RUN go build https.go

FROM scratch
COPY --from=installer ["/opt/output", "/"]
COPY --from=builder ["/go/src/app/https", "/"]
CMD ["/https"]
