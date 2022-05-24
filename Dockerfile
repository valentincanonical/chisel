FROM golang:1.18 as builder
RUN mkdir /build
ADD . /build/
WORKDIR /build/
RUN cd cmd && ./mkversion.sh
RUN CGO_ENABLED=0 GOOS=linux go build -o $(pwd) -a $(pwd)/cmd/chisel

FROM public.ecr.aws/lts/ubuntu:22.04 as chisel
COPY --from=builder /build/chisel /usr/bin/
ENTRYPOINT [ "/usr/bin/chisel" ]
CMD [ "help" ]
# docker build . -t chisel:latest
# mkdir example/output
# docker run -v $(pwd)/examples:/opt --rm chisel cut --release /opt/release/ --root /opt/output/ ca-certificates.static
