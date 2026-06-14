#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

UPSTREAMS_FILE="${UPSTREAMS_FILE:-upstreams.json}"

: "${ARTIFACT_PREFIX:?}"
: "${GITHUB_ENV:?}"
: "${VERSION_SOURCE:?}"

validate_version_part() {
    local part="$1"

    if ! [[ "$part" =~ ^[0-9]+$ ]]; then
        echo "Version part is not numeric: $part"
        exit 1
    fi

    if [ "${#part}" -gt 9 ]; then
        echo "Version part exceeds Firefox's 9-digit limit: $part"
        exit 1
    fi

    if [[ "$part" =~ ^0[0-9]+$ ]]; then
        echo "Version part has a leading zero: $part"
        exit 1
    fi
}

validate_firefox_version() {
    local version="$1"
    local parts_count
    local part

    if ! [[ "$version" =~ ^[0-9]+(\.[0-9]+){0,3}$ ]]; then
        echo "Firefox extension version must have 1 to 4 numeric dot-separated parts: $version"
        exit 1
    fi

    IFS='.' read -r -a version_parts <<<"$version"
    parts_count="${#version_parts[@]}"

    if [ "$parts_count" -lt 1 ] || [ "$parts_count" -gt 4 ]; then
        echo "Firefox extension version must have 1 to 4 parts: $version"
        exit 1
    fi

    for part in "${version_parts[@]}"; do
        validate_version_part "$part"
    done
}

set_common_env() {
    local release_version="$1"
    local release_name="$2"

    validate_firefox_version "$release_version"

    {
        echo "RELEASE_VERSION=${release_version}"
        echo "ARTIFACT_NAME=${ARTIFACT_PREFIX}-${release_version}.xpi"
        echo "RELEASE_TAG=${ARTIFACT_PREFIX}-v${release_version}"
        echo "RELEASE_NAME=${release_name}"
    } >>"$GITHUB_ENV"
}

set_calver_version() {
    local time_version
    local release_version

    time_version=$((10#$(date +'%H') * 10000 + 10#$(date +'%M') * 100 + 10#$(date +'%S')))
    release_version="$(date +'%Y.%-m.%-d').${time_version}"

    set_common_env "$release_version" "${ARTIFACT_PREFIX} v${release_version}"
}

set_package_json_version() {
    local upstream_version
    local last_upstream_version
    local version_build
    local next_version_build
    local release_version
    local version_part_count

    : "${RELEASE_EXTENSION:?}"

    upstream_version=$(jq --raw-output '.version' src/package.json)
    validate_firefox_version "$upstream_version"

    last_upstream_version=$(jq --raw-output --arg extension "$RELEASE_EXTENSION" \
        '.extensions[$extension].last_upstream_version // ""' "$UPSTREAMS_FILE")
    version_build=$(jq --raw-output --arg extension "$RELEASE_EXTENSION" \
        '.extensions[$extension].version_build // 0' "$UPSTREAMS_FILE")

    if ! [[ "$version_build" =~ ^[0-9]+$ ]]; then
        echo "Stored version_build must be a non-negative integer: $version_build"
        exit 1
    fi

    if [ "$upstream_version" = "$last_upstream_version" ]; then
        next_version_build=$((version_build + 1))
    else
        next_version_build=0
    fi

    if [ "$next_version_build" -gt 999999999 ]; then
        echo "version_build exceeds Firefox's 9-digit version part limit: $next_version_build"
        exit 1
    fi

    version_part_count=$(awk -F. '{ print NF }' <<<"$upstream_version")

    if [ "$next_version_build" -eq 0 ]; then
        release_version="$upstream_version"
    else
        if [ "$version_part_count" -ge 4 ]; then
            echo "Cannot append build number to a 4-part upstream version: $upstream_version"
            exit 1
        fi

        release_version="${upstream_version}.${next_version_build}"
    fi

    set_common_env "$release_version" "${ARTIFACT_PREFIX} v${release_version} (upstream ${upstream_version})"

    {
        echo "RELEASE_VERSION_NAME=${upstream_version}"
        echo "UPSTREAM_VERSION=${upstream_version}"
        echo "VERSION_BUILD=${next_version_build}"
    } >>"$GITHUB_ENV"
}

case "$VERSION_SOURCE" in
    calver)
        set_calver_version
        ;;
    package-json)
        set_package_json_version
        ;;
    *)
        echo "Unsupported VERSION_SOURCE: $VERSION_SOURCE"
        exit 1
        ;;
esac
