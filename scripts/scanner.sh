#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

TARGET="$1"
OUTDIR="$2"
BASE_DIR="$3"

mkdir -p "$OUTDIR/scans"
mkdir -p "$OUTDIR/live_hosts"

echo "[+] Scanning: $TARGET"

# -----------------------
# HOST DISCOVERY
# -----------------------
nmap -sn -PS22,80,443 "$TARGET" -oN "$OUTDIR/live_hosts/ping.txt"

grep "Nmap scan report for" "$OUTDIR/live_hosts/ping.txt" \
| awk '{print $NF}' | sort -u > "$OUTDIR/live_hosts/ips.txt"

# fallback
if [ ! -s "$OUTDIR/live_hosts/ips.txt" ]; then
    echo "[-] Fallback scan..."
    nmap -Pn -p 22,80,443 --open "$TARGET" -oN "$OUTDIR/live_hosts/fallback.txt"

    grep "Nmap scan report for" "$OUTDIR/live_hosts/fallback.txt" \
    | awk '{print $NF}' | sort -u > "$OUTDIR/live_hosts/ips.txt"
fi

echo "[+] Live hosts:"
cat "$OUTDIR/live_hosts/ips.txt"


# -----------------------
# RISK ENGINE
# -----------------------
calculate_risk() {
    PORTS="$1"
    SCORE=0

    echo "$PORTS" | grep -q "^445$" && SCORE=$((SCORE+5))
    echo "$PORTS" | grep -q "^22$"  && SCORE=$((SCORE+4))
    echo "$PORTS" | grep -q "^80$"  && SCORE=$((SCORE+3))
    echo "$PORTS" | grep -q "^443$" && SCORE=$((SCORE+3))
    echo "$PORTS" | grep -q "^21$"  && SCORE=$((SCORE+3))

    if [ "$SCORE" -ge 8 ]; then
        echo "HIGH:$SCORE"
    elif [ "$SCORE" -ge 4 ]; then
        echo "MEDIUM:$SCORE"
    else
        echo "LOW:$SCORE"
    fi
}


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

    # FULL SCAN
    nmap -T4 -sC -sV "$IP" -oN "$HOST_DIR/nmap.txt"

    # extract ports (SAFE FORMAT)
    grep "/tcp.*open" "$HOST_DIR/nmap.txt" \
    | awk -F/ '{print $1}' > "$HOST_DIR/ports.txt"

    echo "[+] Ports:"
    cat "$HOST_DIR/ports.txt"

    # -----------------------
    # RISK CALCULATION
    # -----------------------
    RISK=$(calculate_risk "$(cat "$HOST_DIR/ports.txt")")
    echo "[+] RISK: $RISK" | tee "$HOST_DIR/risk.txt"

    # -----------------------
    # DECISION ENGINE
    # -----------------------
    if echo "$RISK" | grep -q "HIGH"; then
        echo "[!] HIGH risk → full enum"
        bash "$SCRIPT_DIR/enum.sh" "$IP" "$HOST_DIR" "$BASE_DIR"

    elif echo "$RISK" | grep -q "MEDIUM"; then
        echo "[!] MEDIUM risk → partial scan"
        bash "$SCRIPT_DIR/enum.sh" "$IP" "$HOST_DIR" "$BASE_DIR"

    else
        echo "[-] LOW risk → skipping heavy enum"
    fi

) &
done < "$OUTDIR/live_hosts/ips.txt"

wait

echo "[+] Scan complete"