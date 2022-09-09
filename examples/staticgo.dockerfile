# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /staging
RUN [ "chisel", "cut", "--release", "ubuntu-22.04", \
    "--root", "/staging/", "ca-certificates_data" ]

FROM public.ecr.aws/lts/ubuntu:22.04 as builder
RUN apt-get update && apt-get install -y golang
WORKDIR /go/src/app
ADD ./src/https.go /go/src/app
RUN CGO_ENABLED=0 go build -a -ldflags="-extldflags=-static" https.go

FROM scratch
COPY --from=installer [ "/staging/", "/" ]
COPY --from=builder [ "/go/src/app/https", "/" ]
CMD [ "/https" ]

# docker run --rm -it $(docker build . -q -f staticgo.dockerfile)