# This Dockerfile is building an image for a simple HTTPS client in Golang that uses a chiselled Ubuntu base image with SSL support

ARG UBUNTU_RELEASE=22.04

FROM public.ecr.aws/lts/ubuntu:${UBUNTU_RELEASE} as builder

RUN apt-get update && apt-get install -y golang
# Updates the package lists and installs the Golang compiler on the current build stage

WORKDIR /go/src/app

ADD ./src/https.go /go/src/app
# Copies the specified "https.go" (our example HTTPS client Go app) file from the host to the current working directory

RUN go build https.go
# Builds the "https.go" file using the Golang compiler and creates an "https" binary in the current working directory

FROM chiselled-ssl-base:${UBUNTU_RELEASE}
# New build stage from the previously built chiselled SSL base image for the specified Ubuntu release (22.04 by default)

COPY --from=builder [ "/go/src/app/https", "/" ]
# Copies the "https" binary from the "builder" build stage to the root directory ("/") of the new image

CMD [ "/https" ]
# Sets the default command to run when the container is started from this image to "/https"

# USAGE:
# 
# 1. Build the "chisel:22.04" image using the "../Dockerfile" file
#    ```  docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04 ```
# 1. Build the chiselled Ubuntu base image with SSL support using the provided "chiselled-ssl-base.dockerfile" file
#    ```  docker build . --build-arg UBUNTU_RELEASE=22.04 -f chiselled-ssl-base.dockerfile -t chiselled-ssl-base:22.04 ```
# 2. Build the "https" image using this Dockerfile
#    ```  docker build . --build-arg UBUNTU_RELEASE=22.04 -f example-ssl.dockerfile -t https ```
# 3. Run the "https" container from the built image
#    ```  docker run --rm -it https ```
#    This will start the HTTPS client and perform a GET request to https://golang.org/
#    The output will be the status of the request (not the content of the retrieved page).
# 5. Make sure the output shows the current date and time, and an "ok" status!
