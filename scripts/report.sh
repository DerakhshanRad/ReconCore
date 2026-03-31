#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

TARGET="$1"
OUTDIR="$2"
BASE_DIR="$3"

if [ -z "$TARGET" ] || [ -z "$OUTDIR" ]; then
    echo "Usage: scanner.sh <target> <outdir> <base_dir>"
    exit 1
fi

mkdir -p "$OUTDIR/scans"
mkdir -p "$OUTDIR/live_hosts"

echo "[+] Scanning: $TARGET"

# -----------------------
# HOST DISCOVERY
# -----------------------
nmap -sn -PS22,80,443 "$TARGET" -oN "$OUTDIR/live_hosts/ping.txt"

grep "Nmap scan report for" "$OUTDIR/live_hosts/ping.txt" \
| awk '{print $NF}' \
| sort -u > "$OUTDIR/live_hosts/ips.txt"

# fallback
if [ ! -s "$OUTDIR/live_hosts/ips.txt" ]; then
    echo "[-] Fallback scan..."

    nmap -Pn -p 22,80,443 --open "$TARGET" -oN "$OUTDIR/live_hosts/fallback.txt"

    grep "Nmap scan report for" "$OUTDIR/live_hosts/fallback.txt" \
    | awk '{print $NF}' \
    | sort -u > "$OUTDIR/live_hosts/ips.txt"
fi

echo "[+] Live hosts:"
cat "$OUTDIR/live_hosts/ips.txt"

# -----------------------
# PER HOST SCAN (PARALLEL)
# -----------------------

while read -r IP; do
(
    IP=$(echo "$IP" | tr -d '\r' | xargs)
    [ -z "$IP" ] && exit

    echo "[+] Scanning host: $IP"

    SAFE_IP=$(echo "$IP" | tr '.' '_')
    HOST_DIR="$OUTDIR/scans/$SAFE_IP"

    mkdir -p "$HOST_DIR"

    # fast scan
    nmap -T4 -sC -sV "$IP" -oN "$HOST_DIR/nmap.txt"

    # extract open ports
    grep "/tcp.*open" "$HOST_DIR/nmap.txt" \
    | awk -F/ '{print $1}' > "$HOST_DIR/ports.txt"

    echo "[+] Ports: $IP"
    cat "$HOST_DIR/ports.txt"

    # ENUMERATION CALL (FIXED)
    if [ -s "$HOST_DIR/ports.txt" ]; then
        bash "$SCRIPT_DIR/enum.sh" "$IP" "$HOST_DIR" "$BASE_DIR"
    fi

) &
done < "$OUTDIR/live_hosts/ips.txt"

wait

echo "[+] Scan complete"