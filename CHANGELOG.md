# Changelog

The ContainerSSH guest image is a rolling release based on Ubuntu 20.04. It is intended as a default guest image for use with ContainerSSH.

## 2020-12-24: Added guest agent

We have added the [ContainerSSH guest agent](https://github.com/containerssh/agent) to the image to ensure compatibility with 0.4. Additionally, we have added an update step to make sure the image is always on the latest patch level.

## 2020-12-13: Automated builds

We are now continuously rebuilding this image daily to ensure it is kept up to date.