#!/usr/bin/bash

set -e

APPS="$(readlink -f "$(dirname "$0")/../apps")"

for dockerfile in "$APPS"/*/Dockerfile; do
    image="$(basename "$(dirname "$dockerfile")")"
    if grep -q "^ARG base_image=\${REGISTRY}" "$dockerfile"; then
        base_image="$(sed -n -e "/^ARG base_image=\\\${REGISTRY}/{ s/^.*}//; s/_/-/g; p }" "$dockerfile")"
        echo "$image swh-${base_image}"
    fi
done
