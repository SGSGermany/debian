Debian GNU/Linux
================

[`debian`](https://ghcr.io/sgsgermany/debian) is [@SGSGermany](https://github.com/SGSGermany)'s base image for containers based on [Debian GNU/Linux](https://www.debian.org/). This image is built *daily* at 21:20 UTC on top of the [official Docker image](https://hub.docker.com/_/debian) using [GitHub Actions](https://github.com/SGSGermany/debian/actions/workflows/container-publish.yml).

Rebuilds are triggered only if Debian builds a new image, or if one of the [`debuerreotype`](https://github.com/debuerreotype/debuerreotype) base packages were updated. Currently we create images for **Debian 13 "Trixie"**, and **Debian 12 "Bookworm"**. Please note that we might add or drop branches at any time, but usually around upstream's release resp. end-of-life dates.

All images are tagged with their full Debian version string, build date and build job number (e.g. `v11.3-20190618.1658821493.1`). The latest build of a Debian release is additionally tagged without the build information (e.g. `v11.3`). If an image represents the latest version of a Debian release branch, it is additionally tagged without the minor version (e.g. `v11`) and with the release branch's codename (e.g. `bullseye`); both without and with build information (e.g. `v11-20190618.1658821493.1` and  `bullseye-20190618.1658821493.1`). The latest build of the latest Debian version is furthermore tagged with `latest`.

Licensing
---------

Made with ♥ by [SGS Serious Gaming & Simulations](https://www.sgs-online.info).

This repository contains scripts and resources for building and continuously integrating an OCI container image, as well as components used to run it (e.g., setup scripts, runtime configuration, modified config files).

All contents of this repository are free and open-source software, licensed under the terms of the [MIT License](./LICENSE).

Please note that the resulting OCI container image includes not only the components provided in this repository, but also the third-party components constituting the operating system included in the image. These are licensed under their respective licenses and are not covered by the MIT License of this repository. Please refer to the respective component licenses for details.
