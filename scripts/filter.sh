#!/bin/bash

#!/bin/bash

INPUT="$1"
OUTPUT="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "Usage: filter.sh <input> <output>"
    exit 1
fi

cat "$INPUT" \
    | tr -d '\r' \
    | sed 's/^[ \t]*//;s/[ \t]*$//' \
    | grep -v '^$' \
    | sort -u \
    > "$OUTPUT"

echo "[+] Filtered targets saved to $OUTPUT"