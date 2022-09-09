FROM golang:1.18 as builder
RUN mkdir /build
ADD . /build/
WORKDIR /build/
RUN cd cmd && ./mkversion.sh
RUN go build -o $(pwd) $(pwd)/cmd/chisel

FROM public.ecr.aws/lts/ubuntu:22.04 as installer
RUN apt-get update && apt-get install -y ca-certificates
COPY --from=builder /build/chisel /usr/bin/
WORKDIR /opt
RUN mkdir /opt/output/
RUN chisel cut --root /opt/output/ libc6_libs ca-certificates_data

FROM scratch
COPY --from=installer ["/opt/output", "/"]
COPY --from=builder /build/chisel /usr/bin/
ENTRYPOINT [ "/usr/bin/chisel" ]
CMD [ "--help" ]

# docker build . -t chisel:latest
# mkdir examples/output
# docker run -v $(pwd)/examples:/opt --rm chisel cut --release /opt/release/ --root /opt/output/ ca-certificates.static
