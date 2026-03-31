#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")

TARGET_FILE="$BASE_DIR/input/target.txt"
FILTERED_FILE="$BASE_DIR/input/targets_clean.txt"

# STEP 1: filter targets
bash "$SCRIPT_DIR/filter.sh" "$TARGET_FILE" "$FILTERED_FILE"

# STEP 2: loop targets
while IFS= read -r TARGET || [ -n "$TARGET" ]; do

    TARGET=$(echo "$TARGET" | tr -d '\r' | xargs)

    [ -z "$TARGET" ] && continue

    SAFE_TARGET=$(echo "$TARGET" | tr '/' '_' | tr -d ' ')
    OUTDIR="$BASE_DIR/output/$SAFE_TARGET"

    echo "[+] Target: $TARGET"
    echo "[+] Output: $OUTDIR"

    mkdir -p "$OUTDIR"

    bash "$SCRIPT_DIR/scanner.sh" "$TARGET" "$OUTDIR" "$BASE_DIR"

done < "$FILTERED_FILE"