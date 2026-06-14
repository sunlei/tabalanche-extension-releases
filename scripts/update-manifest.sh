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
jq 'del(.key)' "$MANIFEST_PATH" >/tmp/manifest.json
mv /tmp/manifest.json "$MANIFEST_PATH"

# Update `version`
jq \
    --arg version "$RELEASE_VERSION" \
    '.version = $version' \
    "$MANIFEST_PATH" >/tmp/manifest.json
mv /tmp/manifest.json "$MANIFEST_PATH"

if [ -n "${RELEASE_VERSION_NAME:-}" ]; then
    jq \
        --arg version_name "$RELEASE_VERSION_NAME" \
        '.version_name = $version_name' \
        "$MANIFEST_PATH" >/tmp/manifest.json
    mv /tmp/manifest.json "$MANIFEST_PATH"
fi

# Update `gecko.id`
jq \
    --arg gecko_id "$GECKO_ID" \
    '.browser_specific_settings.gecko.id = $gecko_id' \
    "$MANIFEST_PATH" >/tmp/manifest.json
mv /tmp/manifest.json "$MANIFEST_PATH"

# Update `gecko.update_url`
jq \
    --arg update_url "$UPDATE_URL" \
    '.browser_specific_settings.gecko.update_url = $update_url' \
    "$MANIFEST_PATH" >/tmp/manifest.json
mv /tmp/manifest.json "$MANIFEST_PATH"

cat "$MANIFEST_PATH"
