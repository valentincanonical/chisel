
FROM chisel:22.04 as installer
# This Dockerfile is building from the "chisel:22.04" image, which has been built using the "../Dockerfile" file with the argument "UBUNTU_RELEASE=22.04"
# ``` docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04 ```

WORKDIR /staging
# Sets the working directory to "/staging"

RUN ["chisel", "cut", "--root", "/staging", \
    "base-files_base", \
    "base-files_release-info", \
    "ca-certificates_data", \
    "libc6_libs" ]
# Runs the "chisel" command with the "cut" option, setting the root directory to "/staging" and cutting the specified files/directories

FROM scratch
# Starts a new build stage from the "scratch" image, which is an empty image with no files or libraries

COPY --from=installer [ "/staging/", "/" ]
# Copies the files from the previous build stage ("installer") at the "/staging" directory to the root directory ("/") of the new image

# *** USAGE (run from the host, not from the DevContainer) ***
# This provides the usage instructions for building the "chiselled-base:22.04" image from this Dockerfile:
# 1. Build the "chisel:22.04" image using the "../Dockerfile" file with the argument "UBUNTU_RELEASE=22.04"
#    ``` docker build .. --build-arg UBUNTU_RELEASE=22.04 -t chisel:22.04 ```
# 2. Build the "chiselled-base:22.04" image using this Dockerfile
#    ``` docker build . -t chiselled-base:22.04 -f chiselled-base.dockerfile ```
