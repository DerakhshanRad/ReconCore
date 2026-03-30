#!/bin/bash

IP=$1
OUTDIR=$2
BASE_DIR=$3

PORT_FILE="$OUTDIR/ports.txt"

echo ""
echo "[+] ENUMERATION: $IP"

while read -r PORT; do

    case $PORT in

        445)
            bash $BASE_DIR/modules/smb.sh $IP $OUTDIR
            ;;

        80|443|8080|8000|9090)
            bash $BASE_DIR/modules/web.sh $IP $PORT $OUTDIR $BASE_DIR
            ;;

        22)
            bash $BASE_DIR/modules/ssh.sh $IP
            ;;

        21)
            bash $BASE_DIR/modules/ftp.sh $IP $OUTDIR
            ;;

        *)
            echo "[-] Skipping port $PORT"
            ;;
    esac

done < "$PORT_FILE"

bash $BASE_DIR/scripts/report.sh $IP $OUTDIR