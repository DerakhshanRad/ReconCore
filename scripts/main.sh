#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")

TARGET_FILE="$BASE_DIR/input/target.txt"

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

done < "$TARGET_FILE"