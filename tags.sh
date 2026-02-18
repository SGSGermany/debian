#!/bin/bash
# Debian GNU/Linux
# @SGSGermany's base image for containers based on Debian GNU/Linux.
#
# Copyright (c) 2022  SGS Serious Gaming & Simulations GmbH
#
# This work is licensed under the terms of the MIT license.
# For a copy, see LICENSE file or <https://opensource.org/licenses/MIT>.
#
# SPDX-License-Identifier: MIT
# License-Filename: LICENSE

set -eu -o pipefail
export LC_ALL=C.UTF-8

[ -v CI_TOOLS ] && [ "$CI_TOOLS" == "SGSGermany" ] \
    || { echo "Invalid build environment: Environment variable 'CI_TOOLS' not set or invalid" >&2; exit 1; }

[ -v CI_TOOLS_PATH ] && [ -d "$CI_TOOLS_PATH" ] \
    || { echo "Invalid build environment: Environment variable 'CI_TOOLS_PATH' not set or invalid" >&2; exit 1; }

[ -x "$(type -P podman 2>/dev/null)" ] \
    || { echo "Missing script dependency: podman" >&2; exit 1; }

[ -x "$(type -P skopeo 2>/dev/null)" ] \
    || { echo "Missing script dependency: skopeo" >&2; exit 1; }

[ -x "$(type -P jq 2>/dev/null)" ] \
    || { echo "Missing script dependency: jq" >&2; exit 1; }

source "$CI_TOOLS_PATH/helper/common.sh.inc"

BUILD_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
source "$BUILD_DIR/container.env"

BUILD_INFO=""
if [ $# -gt 0 ] && [[ "$1" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
    BUILD_INFO=".${1,,}"
fi

# pull base image
echo + "IMAGE_ID=\"\$(podman pull $(quote "$BASE_IMAGE"))\"" >&2
IMAGE_ID="$(podman pull "$BASE_IMAGE" || true)"

if [ -z "$IMAGE_ID" ]; then
    echo "Failed to pull image '$BASE_IMAGE': No image with this tag found" >&2
    exit 1
fi

# read Debian's version file
echo + "VERSION=\"\$(podman run -i --rm $IMAGE_ID cat /etc/debian_version)\"" >&2
VERSION="$(podman run -i --rm "$IMAGE_ID" cat /etc/debian_version)"

if [ -z "$VERSION" ]; then
    echo "Unable to read Debian's version file '/etc/debian_version': Unable to read from file" >&2
    exit 1
elif ! [[ "$VERSION" =~ ^([0-9]+)\.([0-9]+)$ ]]; then
    echo "Unable to read Debian's version file '/etc/debian_version': '$VERSION' is no valid version" >&2
    exit 1
fi

VERSION_MAJOR="${BASH_REMATCH[1]}"

# read codename from Debian's OS release file
echo + "CODENAME=\"\$(podman run -i --rm $IMAGE_ID sh -c '. /etc/os-release ; echo \"\$VERSION_CODENAME\"')\"" >&2
CODENAME="$(podman run -i --rm "$IMAGE_ID" sh -c '. /etc/os-release ; echo "$VERSION_CODENAME"')"

if [ -z "$CODENAME" ]; then
    echo "Unable to read Debian's OS release file '/etc/os-release': Unable to read from file" >&2
    exit 1
fi

# list all available tags of the base image do determine the respective latest version of a branch
ls_versions() {
    jq -re --arg "VERSION" "$1" \
        '.Tags[]|select(test("^[0-9]+\\.[0-9]+$") and startswith($VERSION + "."))' \
        <<< "$BASE_IMAGE_REPO_TAGS" | sort_semver
}

echo + "BASE_IMAGE_REPO_TAGS=\"\$(skopeo list-tags $(quote "docker://${BASE_IMAGE%:*}"))\"" >&2
BASE_IMAGE_REPO_TAGS="$(skopeo list-tags "docker://${BASE_IMAGE%:*}" || true)"

if ! jq -e '.Tags[]' &> /dev/null <<< "$BASE_IMAGE_REPO_TAGS"; then
    echo "Unable to read image tags from container repository 'docker://${BASE_IMAGE%:*}'" >&2
    exit 1
fi

# build tags
BUILD_INFO="$(date --utc +'%Y%m%d')$BUILD_INFO"

TAGS=( "v$VERSION" "v$VERSION-$BUILD_INFO" )

if [ "$VERSION" == "$(ls_versions "$VERSION_MAJOR" | head -n 1)" ]; then
    TAGS+=( "v$VERSION_MAJOR" "v$VERSION_MAJOR-$BUILD_INFO" )
    TAGS+=( "$CODENAME" "$CODENAME-$BUILD_INFO" )

    if ! ls_versions "$((VERSION_MAJOR + 1))" > /dev/null; then
        TAGS+=( "latest" )
    fi
fi

printf 'MILESTONE="%s"\n' "$VERSION_MAJOR"
printf 'VERSION="%s"\n' "$VERSION"
printf 'TAGS="%s"\n' "${TAGS[*]}"
