# first, build the "chisel" image with ../Dockerfile
FROM chisel:latest as installer
WORKDIR /opt
RUN mkdir /opt/output/
ADD ./release/ /opt/release/
RUN chisel cut --release /opt/release/ --root /opt/output/ libc6.runtime openssl.bins

FROM scratch
COPY --from=installer ["/opt/output", "/"]
