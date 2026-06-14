#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

UPSTREAMS_FILE="${UPSTREAMS_FILE:-upstreams.json}"

: "${GITHUB_ENV:?}"
: "${RELEASE_EXTENSION:?}"
: "${UPDATE_BASE_URL:?}"

if ! jq --exit-status --arg extension "$RELEASE_EXTENSION" '.extensions[$extension]' "$UPSTREAMS_FILE" >/dev/null; then
    echo "Unsupported extension: $RELEASE_EXTENSION"
    exit 1
fi

extension_field() {
    local field="$1"

    jq --exit-status --raw-output \
        --arg extension "$RELEASE_EXTENSION" \
        --arg field "$field" \
        '.extensions[$extension][$field] // empty' \
        "$UPSTREAMS_FILE"
}

GECKO_ID=$(extension_field gecko_id)
ARTIFACT_PREFIX=$(extension_field artifact_prefix)
EXTENSION_SOURCE_DIR=$(extension_field source_dir)
UPDATES_FILE=$(extension_field updates_file)
VERSION_SOURCE=$(extension_field version_source)

{
    echo "GECKO_ID=${GECKO_ID}"
    echo "ARTIFACT_PREFIX=${ARTIFACT_PREFIX}"
    echo "EXTENSION_SOURCE_DIR=${EXTENSION_SOURCE_DIR}"
    echo "UPDATES_FILE=${UPDATES_FILE}"
    echo "UPDATE_URL=${UPDATE_BASE_URL}/${UPDATES_FILE}"
    echo "VERSION_SOURCE=${VERSION_SOURCE}"
} >>"$GITHUB_ENV"
