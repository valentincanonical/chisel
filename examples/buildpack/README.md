## Quick intro of cloud-native buildpacks

Each buildpack comprises of two phases - Detect phase , Build phase

A builder image is created by taking a build image and adding a lifecycle, buildpacks, and files that configure aspects of the build including the buildpack detection order and the location(s) of the run image

![](https://buildpacks.io/docs/concepts/components/create-builder.svg)

A stack is composed of **two images** that are intended to work together:
1. The **build image** provides the base image from which the (containerized) build environment is constructed (where the [lifecycle](https://buildpacks.io/docs/concepts/components/lifecycle/) (and thus [buildpacks](https://buildpacks.io/docs/concepts/components/buildpack/)) are executed).
2. The **run image** provides the base image from which application images are built.

## Tutorial to build a buildpack-compatible run image with chiselled ubuntu containers

1. CNB run images need some metadata. Let’s at least add the `io.buildpacks.stack.id` label to our image Dockerfile:

Instead of building a chiselled Ubuntu container from scratch, as shown with [the other examples](../distroless.dockerfile), we will use one of the published chiselled Ubuntu containers for .NET on [hub.docker.com/r/ubuntu/dotnet-aspnet](https://hub.docker.com/r/ubuntu/dotnet-aspnet).

```Dockerfile
FROM ubuntu/dotnet-runtime:6.0-22.04_edge
LABEL io.buildpacks.stack.id="io.buildpacks.stacks.jammy"
```

(See the run image Dockerfile content, [here](./run.dockerfile).)

2. Build a new CNB run image from the chiselled Ubuntu container:

```sh
docker build . -f run.dockerfile -t chiselled-ubuntu-dotnet6:22.04
```

3. Apart from a run image, we also need a bloated build image, with the SDK toolchain installed.
There are many CNB Stacks out there, but for the example we will build one based on Jammy and with the .NET toolchain.

See the build image Dockerfile content, [here](./build.dockerfile).

```sh
docker build . -f build.dockerfile -t ubuntu-dotnet6:22.04-builder
```

4. Finally, we need to create a [“builder.toml”](./builder.toml), where “run-image” is our previously labelled "chiselled-ubuntu-dotnet6:22.04", “build-image” is the bloated Ubuntu w/ .NET image from the previous step (“ubuntu-dotnet6:22.04-builder”), and, most importantly, the buildpack we want to use is the “dotnet-core”, from paketo buildpacks.

See the builder config file content, [here](./builder.toml).

5. Now we can proceed to create the new CNB builder with the `pack` [command line](https://buildpacks.io/docs/tools/pack/).

```sh
pack builder create ubuntu-dotnet6:22.04-builder --config ./builder.toml -v
```

6. Then, to make use of the buildpack, we need to define the source code for our CNB application build.

Let’s use the .NET tests from https://github.com/ubuntu-rocks/dotnet/ (under tests/app_helloworld/src).

First, let's get clone the source code that we want to containerise through the use of buildpacks.

```sh
git clone https://github.com/ubuntu-rocks/dotnet/
```

Then, let's pack the app using our CNB builder:
```sh
pack build my-dotnet-app-chiselled-ubuntu --builder ubuntu-dotnet6:22.04-builder --path dotnet/tests/app_helloworld/src/
```

7. We're done!

Test the new app image

```sh
$ docker run --rm my-dotnet-app-chiselled-ubuntu

Hello, World!
```
