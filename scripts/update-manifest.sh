#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail


# Update manifest.json with version
jq \
    --arg version "$CALVER_VERSION" \
    '.version = $version' \
    src/manifest.json > /tmp/manifest.tmp.json
    mv /tmp/manifest.tmp.json src/manifest.json

# Update manifest.json with gecko.id
jq \
    --arg gecko_id "$GECKO_ID" \
    '.browser_specific_settings.gecko.id = $gecko_id' \
    src/manifest.json > /tmp/manifest.tmp.json
    mv /tmp/manifest.tmp.json src/manifest.json

# Update manifest.json with gecko.update_url
jq \
    --arg update_url "$UPDATE_URL" \
    '.browser_specific_settings.gecko.update_url = $update_url' \
    src/manifest.json > /tmp/manifest.tmp.json
    mv /tmp/manifest.tmp.json src/manifest.json



cat src/manifest.json
