#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

: "${ARTIFACT_NAME:?}"
: "${CALVER_VERSION:?}"
: "${GECKO_ID:?}"
: "${RELEASE_BASE_URL:?}"
: "${RELEASE_TAG:?}"
: "${UPDATES_FILE:?}"

XPI_URL="$RELEASE_BASE_URL/$RELEASE_TAG/$ARTIFACT_NAME"
TMP_UPDATES_FILE=$(mktemp)

jq --raw-output \
    --arg GECKO_ID "${GECKO_ID}" \
    --arg CALVER_VERSION "${CALVER_VERSION}" \
    --arg XPI_URL "${XPI_URL}" \
    '.addons[$GECKO_ID].updates = ((.addons[$GECKO_ID].updates // []) + [{"version": $CALVER_VERSION, "update_link": $XPI_URL }])' \
    "$UPDATES_FILE" >"$TMP_UPDATES_FILE"
mv "$TMP_UPDATES_FILE" "$UPDATES_FILE"

cat "$UPDATES_FILE"
