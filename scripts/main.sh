#!/bin/bash

# Get base directory
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BASE_DIR=$(dirname "$SCRIPT_DIR")

TARGET_FILE="$BASE_DIR/input/target.txt"

while read -r TARGET; do
    CLEAN_TARGET=$(echo $TARGET | tr -d '\r')
    SAFE_TARGET=$(echo $CLEAN_TARGET | tr '/' '_')
    
    OUTDIR="$BASE_DIR/output/$SAFE_TARGET"
    
    echo "[+] Processing subnet: $CLEAN_TARGET"
    
    mkdir -p $OUTDIR/{scans,live_hosts}
    
    echo "[+] Running fast host discovery..."
    nmap -sn -PS80,443,22 $CLEAN_TARGET -oN $OUTDIR/live_hosts/ping.txt
    
    grep "Nmap scan report" $OUTDIR/live_hosts/ping.txt | awk '{print $5}' > $OUTDIR/live_hosts/ips.txt
    
    if [ ! -s $OUTDIR/live_hosts/ips.txt ]; then
        echo "[-] No hosts found. Trying fallback (-Pn)..."
        
        nmap -Pn -p 80,443,22 --open $CLEAN_TARGET -oN $OUTDIR/live_hosts/fallback.txt
        
        grep "Nmap scan report" $OUTDIR/live_hosts/fallback.txt | awk '{print $5}' > $OUTDIR/live_hosts/ips.txt
    fi
    
    echo "[+] Live hosts:"
    cat $OUTDIR/live_hosts/ips.txt
    
    while read -r IP; do
        echo "[+] Scanning host: $IP"
        
        HOST_DIR="$OUTDIR/scans/$IP"
        mkdir -p $HOST_DIR
        
        # Scan
        nmap -T4 -sC -sV -oN $HOST_DIR/nmap.txt $IP
        
        # Extract ports
        grep open $HOST_DIR/nmap.txt | cut -d "/" -f1 > $HOST_DIR/ports.txt
        
        # Decision engine
        if [ -s $HOST_DIR/ports.txt ]; then
            $SCRIPT_DIR/enum.sh $IP $HOST_DIR $BASE_DIR
        else
            echo "[-] No open ports on $IP"
        fi
        
    done < $OUTDIR/live_hosts/ips.txt
        
    echo "[+] Finished subnet: $CLEAN_TARGET"
    echo "----------------------------------------"

done < $TARGET_FILE