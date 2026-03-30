#!/bin/bash

IP=$1
OUTDIR=$2

echo "[ SMB HIGH VALUE] $IP"

mkdir -p $OUTDIR/smb

echo "[+] smbclient"
echo "smbclient -L //$IP -N"

echo "[+] enum4linux"
echo "enum4linux -a $IP"

nmap --script smb-enum-shares -p 445 $IP \
    -oN $OUTDIR/smb/nmap_smb.txt