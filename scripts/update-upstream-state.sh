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
VERSION_BUILD_JSON="${VERSION_BUILD:-null}"

jq \
    --arg extension "$RELEASE_EXTENSION" \
    --arg upstream_sha "$UPSTREAM_SHA" \
    --arg upstream_version "${UPSTREAM_VERSION:-}" \
    --argjson version_build "$VERSION_BUILD_JSON" \
    '.extensions[$extension].last_seen = $upstream_sha
    | if $upstream_version == "" then . else .extensions[$extension].last_upstream_version = $upstream_version end
    | if $version_build == null then . else .extensions[$extension].version_build = $version_build end' \
    "$UPSTREAMS_FILE" >"$TMP_UPSTREAMS_FILE"
mv "$TMP_UPSTREAMS_FILE" "$UPSTREAMS_FILE"

cat "$UPSTREAMS_FILE"
