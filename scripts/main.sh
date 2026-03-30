#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")

TARGET_FILE="$BASE_DIR/input/target.txt"

while read -r TARGET; do
    CLEAN_TARGET=$(echo $TARGET | tr -d '\r')
    OUTDIR="$BASE_DIR/output/$CLEAN_TARGET"

    echo "[+] Target: $CLEAN_TARGET"

    mkdir -p $OUTDIR

    bash $SCRIPT_DIR/scanner.sh "$CLEAN_TARGET" "$OUTDIR" "$BASE_DIR"

done < "$TARGET_FILE"