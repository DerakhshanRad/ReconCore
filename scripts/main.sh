#!/bin/bash

TARGET_FILE="../input/target.txt"

while read -r TARGET; do
    CLEAN_TARGET=$(echo $TARGET | tr -d '\r')
    SAFE_TARGET=$(echo $CLEAN_TARGET | tr '/' '_')
    
    OUTDIR="../output/$SAFE_TARGET"
    
    echo "[+] Processing subnet: $CLEAN_TARGET"
    
    mkdir -p $OUTDIR/{scans,live_hosts}
    
    echo "[+] Running fast host discovery..."
    nmap -sn -PS80,443,22 $CLEAN_TARGET -oN $OUTDIR/live_hosts/ping.txt
    
    # Extract live IPs
    grep "Nmap scan report" $OUTDIR/live_hosts/ping.txt | awk '{print $5}' > $OUTDIR/live_hosts/ips.txt
    
    # 🔥 CHECK IF EMPTY
    if [ ! -s $OUTDIR/live_hosts/ips.txt ]; then
        echo "[-] No hosts found with ping scan. Trying fallback (-Pn)..."
        
        # Fallback scan (treat all as alive)
        nmap -Pn -p 80,443,22 --open $CLEAN_TARGET -oN $OUTDIR/live_hosts/fallback.txt
        
        grep "Nmap scan report" $OUTDIR/live_hosts/fallback.txt | awk '{print $5}' > $OUTDIR/live_hosts/ips.txt
    fi
    
    echo "[+] Live hosts:"
    cat $OUTDIR/live_hosts/ips.txt
    
    # Loop through hosts
    while read -r IP; do
        echo "[+] Scanning host: $IP"
        
        HOST_DIR="$OUTDIR/scans/$IP"
        mkdir -p $HOST_DIR
        
        nmap -T4 -sC -sV -oN $HOST_DIR/nmap.txt $IP
        
        # Extract ports
        grep open $HOST_DIR/nmap.txt | cut -d "/" -f1 > $HOST_DIR/ports.txt
        
        echo "[+] Open ports for $IP:"
        cat $HOST_DIR/ports.txt
        
    done < $OUTDIR/live_hosts/ips.txt
    
    echo "[+] Finished subnet: $CLEAN_TARGET"
    echo "----------------------------------------"

done < $TARGET_FILE