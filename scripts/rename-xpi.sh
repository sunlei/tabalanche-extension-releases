#!/usr/bin/env bash

set -o nounset  # set -u
set -o errexit  # set -e
set -o errtrace # set -E
set -o pipefail

XPI_FILES=()
while IFS= read -r -d '' xpi_file; do
    XPI_FILES+=("$xpi_file")
done < <(find "$WEB_EXT_ARTIFACTS_DIR" -maxdepth 1 -type f -name "*.xpi" -print0)

if [ "${#XPI_FILES[@]}" -ne 1 ]; then
    echo "Expected 1 xpi file, found ${#XPI_FILES[@]}"
    exit 1
fi

SIGNED_XPI_FILE="${XPI_FILES[0]}"

if [ -n "$SIGNED_XPI_FILE" ]; then
    mv "$SIGNED_XPI_FILE" "$WEB_EXT_ARTIFACTS_DIR/$ARTIFACT_NAME"
    echo "Renamed signed extension $SIGNED_XPI_FILE to $ARTIFACT_NAME"
else
    echo "No signed extension found"
    exit 1
fi
