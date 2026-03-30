#!/bin/bash

IP=$1
OUTDIR=$2

echo ""
echo "========================"
echo "REPORT: $IP"
echo "========================"

echo ""

if grep -q "445" $OUTDIR/ports.txt; then
    echo " SMB → HIGH VALUE"
fi

if grep -q "80\|443" $OUTDIR/ports.txt; then
    echo " WEB → investigate manually"
fi

if grep -q "22" $OUTDIR/ports.txt; then
    echo " SSH → possible pivot"
fi

echo ""
echo "[+] Done"