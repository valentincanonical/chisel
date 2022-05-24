FROM golang:1.18 as builder
RUN mkdir /build
ADD . /build/
WORKDIR /build/
RUN cd cmd && ./mkversion.sh
RUN go build -o $(pwd) $(pwd)/cmd/chisel

FROM public.ecr.aws/lts/ubuntu:22.04 as installer
COPY --from=builder /build/chisel /usr/bin/
WORKDIR /opt
RUN mkdir /opt/output/
ADD ./examples/release/ /opt/release/
RUN chisel cut --release /opt/release/ --root /opt/output/ libc6.runtime

FROM scratch
COPY --from=installer ["/opt/output", "/"]
COPY --from=builder /build/chisel /usr/bin/
ENTRYPOINT [ "/usr/bin/chisel" ]
CMD [ "help" ]
# docker build . -t chisel:latest
# mkdir examples/output
# docker run -v $(pwd)/examples:/opt --rm chisel cut --release /opt/release/ --root /opt/output/ ca-certificates.static
