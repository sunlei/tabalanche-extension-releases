#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

UPSTREAMS_FILE="${UPSTREAMS_FILE:-upstreams.json}"

: "${GITHUB_EVENT_NAME:?}"
: "${GITHUB_OUTPUT:?}"

if [ ! -f "$UPSTREAMS_FILE" ]; then
    echo "Upstream state file not found: $UPSTREAMS_FILE"
    exit 1
fi

INCLUDE_FILE=$(mktemp)
EXTENSIONS_FILE=$(mktemp)
printf '[]\n' >"$INCLUDE_FILE"

remote_ref() {
    local ref="$1"

    case "$ref" in
        refs/*)
            printf '%s\n' "$ref"
            ;;
        *)
            printf 'refs/heads/%s\n' "$ref"
            ;;
    esac
}

current_upstream_sha() {
    local repository="$1"
    local ref="$2"
    local resolved_ref
    local ls_remote_output

    resolved_ref=$(remote_ref "$ref")
    ls_remote_output=$(git ls-remote "https://github.com/${repository}.git" "$resolved_ref")

    if [ -z "$ls_remote_output" ]; then
        echo "Could not resolve $repository $resolved_ref"
        exit 1
    fi

    printf '%s\n' "$ls_remote_output" | awk 'NR == 1 { print $1 }'
}

append_extension() {
    local extension="$1"
    local upstream_sha="$2"
    local repository="$3"
    local ref="$4"
    local tmp_file

    tmp_file=$(mktemp)
    jq \
        --arg extension "$extension" \
        --arg upstream_sha "$upstream_sha" \
        --arg repository "$repository" \
        --arg ref "$ref" \
        '. + [{"extension": $extension, "upstream_sha": $upstream_sha, "repository": $repository, "ref": $ref}]' \
        "$INCLUDE_FILE" >"$tmp_file"
    mv "$tmp_file" "$INCLUDE_FILE"
}

select_extension() {
    local extension="$1"
    local repository
    local ref
    local last_seen
    local upstream_sha

    if ! jq --exit-status --arg extension "$extension" '.extensions[$extension]' "$UPSTREAMS_FILE" >/dev/null; then
        echo "Unsupported extension: $extension"
        exit 1
    fi

    repository=$(jq --raw-output --arg extension "$extension" '.extensions[$extension].repository' "$UPSTREAMS_FILE")
    ref=$(jq --raw-output --arg extension "$extension" '.extensions[$extension].ref' "$UPSTREAMS_FILE")
    last_seen=$(jq --raw-output --arg extension "$extension" '.extensions[$extension].last_seen // ""' "$UPSTREAMS_FILE")
    upstream_sha=$(current_upstream_sha "$repository" "$ref")

    if [ "$GITHUB_EVENT_NAME" = "workflow_dispatch" ]; then
        echo "$extension: selected manually at $upstream_sha"
        append_extension "$extension" "$upstream_sha" "$repository" "$ref"
        return
    fi

    if [ "$upstream_sha" != "$last_seen" ]; then
        echo "$extension: upstream changed $last_seen -> $upstream_sha"
        append_extension "$extension" "$upstream_sha" "$repository" "$ref"
    else
        echo "$extension: no upstream changes at $upstream_sha"
    fi
}

case "$GITHUB_EVENT_NAME" in
    workflow_dispatch)
        : "${RELEASE_EXTENSION:?}"
        select_extension "$RELEASE_EXTENSION"
        ;;
    schedule)
        jq --raw-output '.extensions | keys[]' "$UPSTREAMS_FILE" >"$EXTENSIONS_FILE"

        while IFS= read -r extension; do
            select_extension "$extension"
        done <"$EXTENSIONS_FILE"
        ;;
    *)
        echo "Unsupported event: $GITHUB_EVENT_NAME"
        exit 1
        ;;
esac

selected_count=$(jq 'length' "$INCLUDE_FILE")

if [ "$selected_count" -gt 0 ]; then
    has_changes=true
    matrix=$(jq --compact-output '{include: .}' "$INCLUDE_FILE")
else
    has_changes=false
    matrix='{"include":[{"extension":"noop","upstream_sha":"","repository":"","ref":""}]}'
fi

{
    echo "has_changes=$has_changes"
    echo "matrix=$matrix"
} >>"$GITHUB_OUTPUT"
