#!/bin/bash

INPUT_FILE=$1
OUTPUT_FILE=$2

echo "[+] Starting target filtering..."

if [ ! -f "$INPUT_FILE" ]; then
    echo "[-] Input file not found: $INPUT_FILE"
    exit 1
fi

# Clean + validate + deduplicate
cat "$INPUT_FILE" \
| tr -d '\r' \
| sed '/^$/d' \
| xargs -n1 \
| grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}(/([0-9]|[12][0-9]|3[0-2]))?$' \
| sort -u > "$OUTPUT_FILE"

echo "[+] Filtering complete"
echo "[+] Clean targets saved to: $OUTPUT_FILE"

echo "[+] Final targets:"
cat "$OUTPUT_FILE"