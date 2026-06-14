#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

MANIFEST_PATH="${EXTENSION_SOURCE_DIR:-src}/manifest.json"

: "${GECKO_ID:?}"
: "${RELEASE_VERSION:?}"
: "${UPDATE_URL:?}"

# Delete `key`
TMP_MANIFEST_PATH=$(mktemp)

jq \
    --arg version "$RELEASE_VERSION" \
    --arg version_name "${RELEASE_VERSION_NAME:-}" \
    --arg gecko_id "$GECKO_ID" \
    --arg update_url "$UPDATE_URL" \
    'del(.key)
    | .version = $version
    | .browser_specific_settings.gecko.id = $gecko_id
    | .browser_specific_settings.gecko.update_url = $update_url
    | if $version_name == "" then . else .version_name = $version_name end' \
    "$MANIFEST_PATH" >"$TMP_MANIFEST_PATH"
mv "$TMP_MANIFEST_PATH" "$MANIFEST_PATH"

cat "$MANIFEST_PATH"
