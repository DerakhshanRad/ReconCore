#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")

FILTERED_FILE="$BASE_DIR/input/targets_clean.txt"

# Run filtering first
bash "$SCRIPT_DIR/filter.sh" \
    "$BASE_DIR/input/target.txt" \
    "$FILTERED_FILE"

# Read CLEAN targets (FIXED HERE)
while IFS= read -r TARGET || [ -n "$TARGET" ]; do

    TARGET=$(echo "$TARGET" | tr -d '\r' | xargs)

    if [ -z "$TARGET" ]; then
        continue
    fi

    SAFE_TARGET=$(echo "$TARGET" | tr '/' '_' | tr -d ' ')

    OUTDIR="$BASE_DIR/output/$SAFE_TARGET"

    echo "[+] Target: $TARGET"
    echo "[+] Safe: $SAFE_TARGET"

    mkdir -p "$OUTDIR"

    bash "$SCRIPT_DIR/scanner.sh" "$TARGET" "$OUTDIR" "$BASE_DIR"

# 🔥 FIX: use FILTERED_FILE instead of TARGET_FILE
done < "$FILTERED_FILE"