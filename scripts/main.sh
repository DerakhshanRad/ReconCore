#!/bin/bash

TARGET_FILE="../input/target.txt"

while read -r TARGET; do
    CLEAN_TARGET=$(echo $TARGET | tr -d '\r')
    SAFE_TARGET=$(echo $CLEAN_TARGET | tr '/' '_')
    
    OUTDIR="../output/$SAFE_TARGET"
    
    echo "[+] Processing subnet: $CLEAN_TARGET"
    
    mkdir -p $OUTDIR/{scans,live_hosts}
    
    echo "[+] Discovering live hosts..."
    
    nmap -sn $CLEAN_TARGET -oN $OUTDIR/live_hosts/ping.txt
    
    # Extract live IPs
    grep "Nmap scan report" $OUTDIR/live_hosts/ping.txt | awk '{print $5}' > $OUTDIR/live_hosts/ips.txt
    
    echo "[+] Live hosts found:"
    cat $OUTDIR/live_hosts/ips.txt
    
    # Loop through each live IP
    while read -r IP; do
        echo "[+] Scanning host: $IP"
        
        mkdir -p $OUTDIR/scans/$IP
        
        nmap -sC -sV -oN $OUTDIR/scans/$IP/nmap.txt $IP
        
    done < $OUTDIR/live_hosts/ips.txt
    
    echo "[+] Finished subnet: $CLEAN_TARGET"

done < $TARGET_FILE