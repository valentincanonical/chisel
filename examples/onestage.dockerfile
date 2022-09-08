FROM public.ecr.aws/lts/ubuntu:22.04 AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y gcc
RUN echo 'main(){printf("hello, world\\n");}' > hello.c
RUN gcc -w hello.c -o ./hello-world

FROM chisel:latest
ADD ./release/ /release/
RUN chisel cut --release /release/ --root / libc6.runtime
COPY --from=builder /app/hello-world /
ENTRYPOINT [""]
CMD ["/hello-world"]
