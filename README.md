Debian GNU/Linux
================

[`debian`](https://ghcr.io/sgsgermany/debian) is [@SGSGermany](https://github.com/SGSGermany)'s base image for containers based on [Debian GNU/Linux](https://www.debian.org/). This image is built *daily* at 21:20 UTC on top of the [official Docker image](https://hub.docker.com/_/debian) using [GitHub Actions](https://github.com/SGSGermany/debian/actions/workflows/container-publish.yml).

Rebuilds are triggered only if Debian builds a new image, or if one of the [`debuerreotype`](https://github.com/debuerreotype/debuerreotype) base packages were updated. Currently we create images for **Debian 12 "Bookworm"**, **Debian 11 "Bullseye"**, and **Debian 10 "Buster"**. Please note that we might add or drop branches at any time.

All images are tagged with their full Debian version string, build date and build job number (e.g. `v11.3-20190618.1658821493.1`). The latest build of a Debian release is additionally tagged without the build information (e.g. `v11.3`). If an image represents the latest version of a Debian release branch, it is additionally tagged without the minor version (e.g. `v11`) and with the release branch's codename (e.g. `bullseye`); both without and with build information (e.g. `v11-20190618.1658821493.1` and  `bullseye-20190618.1658821493.1`). The latest build of the latest Debian version is furthermore tagged with `latest`.
