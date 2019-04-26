# Docker Template

This is a template for making images, you can use this to build on the docker hub
and also on any system with docker installed.

## setup

### Build.sh
this is for building by hand, you can copy the docker_build file and edit with your setting.

1. create ~/.docker_build
2. edit ~/.docker_build with your setting
3. run `./build.sh`

### Build on Docker hub
You can use this template to build images on the docker hub, you need to setup
build rules and add `BUILD ENVIRONMENT VARIABLES`.

- SOURCE_IMAGE
- SOURCE_IMAGE_TAG
