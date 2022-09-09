# STAGE 1: Build Chisel using the Golang SDK
FROM golang:1.18 as builder
RUN mkdir /build
ADD . /build/
WORKDIR /build/
RUN cd cmd && ./mkversion.sh
RUN go build -o $(pwd) $(pwd)/cmd/chisel

# STAGE 2: Create a Chiselled Ubuntu environment for Chisel to run
FROM public.ecr.aws/lts/ubuntu:22.04 as installer
RUN apt-get update && apt-get install -y ca-certificates
COPY --from=builder /build/chisel /usr/bin/
WORKDIR /opt
RUN mkdir /opt/output/
RUN chisel cut --root /opt/output/ libc6_libs ca-certificates_data

# STAGE 3: Assemble the Chisel binary + its chiselled dependencies
FROM scratch
COPY --from=installer ["/opt/output", "/"]
COPY --from=builder /build/chisel /usr/bin/
ENTRYPOINT [ "/usr/bin/chisel" ]
CMD [ "--help" ]

# USAGE
# docker build . -t chisel:latest
# mkdir chiselled
# docker run -v $(pwd)/chiselled:/opt/output --rm chisel cut --release ubuntu-22.04 --root /opt/output/ libc6_libs ca-certificates_data
# ls -la ./chiselled