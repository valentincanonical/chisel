ARG UBUNTU_RELEASE=22.04

FROM public.ecr.aws/lts/ubuntu:${UBUNTU_RELEASE} as builder
RUN apt-get update && apt-get install -y golang
WORKDIR /go/src/app
ADD ./src/https.go /go/src/app
RUN go build https.go

FROM chiselled-ssl-base:${UBUNTU_RELEASE}
COPY --from=builder [ "/go/src/app/https", "/" ]
CMD [ "/https" ]

# docker run --rm -it $(docker build . -q -f example-ssl.dockerfile)
