#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

MANIFEST_PATH="${EXTENSION_SOURCE_DIR:-src}/manifest.json"

# Delete `key`
jq 'del(.key)' "$MANIFEST_PATH" >/tmp/manifest.json
mv /tmp/manifest.json "$MANIFEST_PATH"

# Update `version`
jq \
    --arg version "$CALVER_VERSION" \
    '.version = $version' \
    "$MANIFEST_PATH" >/tmp/manifest.json
mv /tmp/manifest.json "$MANIFEST_PATH"

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
