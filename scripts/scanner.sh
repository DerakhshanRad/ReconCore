#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

TARGET="$1"
OUTDIR="$2"
BASE_DIR="$3"

echo "[DEBUG] scanner.sh started"
echo "[DEBUG] TARGET=$TARGET"
echo "[DEBUG] OUTDIR=$OUTDIR"

# safety checks
if [ -z "$TARGET" ] || [ -z "$OUTDIR" ]; then
    echo "[-] Missing arguments"
    echo "Usage: scanner.sh <target> <outdir> <base_dir>"
    exit 1
fi

mkdir -p "$OUTDIR/scans"
mkdir -p "$OUTDIR/live_hosts"

# -----------------------
# HOST DISCOVERY
# -----------------------
echo "[+] Fast scanning: $TARGET"

nmap -sn -PS22,80,443 "$TARGET" -oN "$OUTDIR/live_hosts/ping.txt"

# extract live IPs safely
grep "Nmap scan report for" "$OUTDIR/live_hosts/ping.txt" \
| awk '{print $NF}' > "$OUTDIR/live_hosts/ips.txt"

echo "[+] Live hosts found:"
cat "$OUTDIR/live_hosts/ips.txt"

# -----------------------
# FALLBACK SCAN (if empty)
# -----------------------
if [ ! -s "$OUTDIR/live_hosts/ips.txt" ]; then
    echo "[-] No hosts found, fallback scan..."

    nmap -Pn -p 22,80,443 --open "$TARGET" \
        -oN "$OUTDIR/live_hosts/fallback.txt"

    grep "Nmap scan report for" "$OUTDIR/live_hosts/fallback.txt" \
    | awk '{print $NF}' > "$OUTDIR/live_hosts/ips.txt"
fi

# -----------------------
# PER HOST SCAN
# -----------------------
while read -r IP; do

    IP=$(echo "$IP" | tr -d '\r' | xargs)

    [ -z "$IP" ] && continue

    echo "[+] Scanning host: $IP"

    SAFE_IP=$(echo "$IP" | tr '.' '_')

    HOST_DIR="$OUTDIR/scans/$SAFE_IP"
    mkdir -p "$HOST_DIR"

    # full scan
    nmap -T4 -sC -sV "$IP" -oN "$HOST_DIR/nmap.txt"

    # extract open ports safely
    grep "/tcp.*open" "$HOST_DIR/nmap.txt" \
    | awk -F/ '{print $1}' > "$HOST_DIR/ports.txt"

    echo "[+] Open ports for $IP:"
    cat "$HOST_DIR/ports.txt"

    # -----------------------
    # CALL ENUM MODULE (FIXED)
    # -----------------------
    if [ -s "$HOST_DIR/ports.txt" ]; then
        bash "$SCRIPT_DIR/enum.sh" "$IP" "$HOST_DIR" "$BASE_DIR"
    else
        echo "[-] No open ports detected for $IP"
    fi

done < "$OUTDIR/live_hosts/ips.txt"

echo "[+] Scan complete"