#!/usr/bin/env bash

set -Eeuo pipefail

SRC_DIR="src/"
DEST_DIR="dst"

RSYNC="rsync --archive --checksum --verbose --delete $SRC_DIR $DEST_DIR"

# Sync files to disk
sync

# Perform first rsync pass to detect and list changes
# updated (prefixed with >), created (prefixed with <), or deleted (prefixed with *deleting)
RSYNC_LIST_OF_CHANGES=$($RSYNC --dry-run --itemize-changes | grep -E '^[>]|^[<]|^\*deleting' | cut -d' ' -f2- || true)

# List changes
test -n "$RSYNC_LIST_OF_CHANGES" && echo "Detected changes: src | dest"
IFS_SAVE=$IFS
IFS=$'\n'
for change in $(printf "%s\n" "$RSYNC_LIST_OF_CHANGES");
do
    SRC=$(ls -adlT "$SRC_DIR/$change" 2>&1 || true)
    DEST=$(ls -adlT "$DEST_DIR/$change" 2>&1 || true)
    echo "$SRC | $DEST"
done
IFS=$IFS_SAVE

# Perform second rsync pass to detect and rsync changes
RSYNC_LIST_OF_CHANGES=$($RSYNC --dry-run --itemize-changes | grep -E '^[>]|^[<]|^\*deleting' | cut -d' ' -f2- || true)
test -n "$RSYNC_LIST_OF_CHANGES" && echo "Rsynced changes"
if test -n "$RSYNC_LIST_OF_CHANGES"; then
    $RSYNC
    exit 1
fi
