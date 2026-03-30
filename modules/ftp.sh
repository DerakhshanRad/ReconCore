#!/bin/bash

IP=$1
OUTDIR=$2

echo "[FTP] $IP"

mkdir -p $OUTDIR/ftp

nmap --script ftp-anon -p 21 $IP \
    -oN $OUTDIR/ftp/ftp.txt