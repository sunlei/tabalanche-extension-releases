#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

XPI_FILE_COUNT=$(ls -1 "$WEB_EXT_ARTIFACTS_DIR"/*.xpi | wc -l)

if [ "$XPI_FILE_COUNT" -ne 1 ]; then
    echo "Expected 1 xpi file, found $XPI_FILE_COUNT"
    exit 1
fi

SIGNED_XPI_FILE=$(find "$WEB_EXT_ARTIFACTS_DIR" -name "*.xpi")

if [ -n "$SIGNED_XPI_FILE" ]; then
    mv "$SIGNED_XPI_FILE" "$WEB_EXT_ARTIFACTS_DIR/$ARTIFACT_NAME"
    echo "Renamed signed extension $SIGNED_XPI_FILE to $ARTIFACT_NAME"
else
    echo "No signed extension found"
    exit 1
fi

ls -alh "$WEB_EXT_ARTIFACTS_DIR"
