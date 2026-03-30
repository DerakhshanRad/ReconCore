#!/bin/bash

IP=$1
PORT=$2
OUTDIR=$3
BASE_DIR=$4

if [ "$PORT" == "443" ]; then
    URL="https://$IP:$PORT"
else
    URL="http://$IP:$PORT"
fi

echo "[WEB] $URL"

mkdir -p $OUTDIR/web

# Quick check
STATUS=$(curl -s -o /dev/null -w "%{http_code}" $URL)

echo "Status: $STATUS"

if [[ "$STATUS" == "200" || "$STATUS" == "301" || "$STATUS" == "302" ]]; then

    echo "[+] Running gobuster"

    gobuster dir \
        -u $URL \
        -w $BASE_DIR/wordlists/common.txt \
        -x php,txt,html \
        -k \
        -o $OUTDIR/web/gobuster.txt \
        2>/dev/null
fi