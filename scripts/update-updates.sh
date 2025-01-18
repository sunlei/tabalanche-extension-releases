#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

XPI_URL="https://github.com/sunlei/tabalanche-extension-releases/releases/download/v$CALVER_VERSION/tabalanche-$CALVER_VERSION.xpi"

jq --raw-output \
    --arg GECKO_ID "${GECKO_ID}" \
    --arg CALVER_VERSION "${CALVER_VERSION}" \
    --arg XPI_URL "${XPI_URL}" \
    '.addons[$GECKO_ID].updates += [{"version": $CALVER_VERSION, "update_link": $XPI_URL }]' \
    updates.json >/tmp/updates.json
mv /tmp/updates.json updates.json

cat updates.json
