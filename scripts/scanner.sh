#!/bin/bash

IP=$1
OUTDIR=$2
BASE_DIR=$3

echo "[+] Fast scanning $IP"

mkdir -p $OUTDIR/scans

# FAST scan first
nmap -T4 --top-ports 100 $IP -oN $OUTDIR/scans/fast.txt

# Extract ports
grep "open" $OUTDIR/scans/fast.txt | cut -d "/" -f1 > $OUTDIR/ports.txt

# Deep scan only if ports found
if [ -s $OUTDIR/ports.txt ]; then
    echo "[+] Deep scan $IP"
    nmap -T4 -sC -sV -p $(cat $OUTDIR/ports.txt | tr '\n' ',') $IP \
        -oN $OUTDIR/scans/deep.txt
fi

bash $BASE_DIR/scripts/enum.sh "$IP" "$OUTDIR" "$BASE_DIR"