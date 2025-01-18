#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

jq --raw-output \
    --arg GECKO_ID "${GECKO_ID}" \
    --arg CALVER_VERSION "${CALVER_VERSION}" \
    --arg XPIPATH "${XPIPATH}" \
    '.addons[$GECKO_ID].updates += [{"version": $CALVER_VERSION, "update_link": $XPIPATH }]' \
    updates.json >/tmp/updates.json
mv /tmp/updates.json updates.json

cat updates.json
