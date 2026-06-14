#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

UPSTREAMS_FILE="${UPSTREAMS_FILE:-upstreams.json}"

: "${RELEASE_EXTENSION:?}"
: "${UPSTREAM_SHA:?}"

if ! jq --exit-status --arg extension "$RELEASE_EXTENSION" '.extensions[$extension]' "$UPSTREAMS_FILE" >/dev/null; then
    echo "Unsupported extension: $RELEASE_EXTENSION"
    exit 1
fi

TMP_UPSTREAMS_FILE=$(mktemp)

jq \
    --arg extension "$RELEASE_EXTENSION" \
    --arg upstream_sha "$UPSTREAM_SHA" \
    '.extensions[$extension].last_seen = $upstream_sha' \
    "$UPSTREAMS_FILE" >"$TMP_UPSTREAMS_FILE"
mv "$TMP_UPSTREAMS_FILE" "$UPSTREAMS_FILE"

if [ -n "${UPSTREAM_VERSION:-}" ]; then
    TMP_UPSTREAMS_FILE=$(mktemp)

    jq \
        --arg extension "$RELEASE_EXTENSION" \
        --arg upstream_version "$UPSTREAM_VERSION" \
        '.extensions[$extension].last_upstream_version = $upstream_version' \
        "$UPSTREAMS_FILE" >"$TMP_UPSTREAMS_FILE"
    mv "$TMP_UPSTREAMS_FILE" "$UPSTREAMS_FILE"
fi

if [ -n "${VERSION_BUILD:-}" ]; then
    TMP_UPSTREAMS_FILE=$(mktemp)

    jq \
        --arg extension "$RELEASE_EXTENSION" \
        --argjson version_build "$VERSION_BUILD" \
        '.extensions[$extension].version_build = $version_build' \
        "$UPSTREAMS_FILE" >"$TMP_UPSTREAMS_FILE"
    mv "$TMP_UPSTREAMS_FILE" "$UPSTREAMS_FILE"
fi

cat "$UPSTREAMS_FILE"
