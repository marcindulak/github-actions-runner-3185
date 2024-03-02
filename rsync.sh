#!/usr/bin/env bash

set -Eeuo pipefail

RSYNC="rsync --archive --verbose --delete src/ dst"
if $RSYNC --dry-run --itemize-changes | grep -Eq '^[>]|^\*deleting'; then
    $RSYNC
    exit 1
fi
