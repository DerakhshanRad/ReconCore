#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

IP=$1
HOST_DIR=$2
BASE_DIR=$3
RUN_GOBUSTER=$4

PORT_FILE="$HOST_DIR/ports.txt"

echo ""
echo "[+] ===== Service Analysis for $IP ====="

while read -r PORT; do

    echo ""
    echo "[DEBUG] Processing port: $PORT"

    case $PORT in

        # ================= WEB =================
        80|443|8080|8000|8888|9090|5001)

            if [ "$PORT" == "443" ]; then
                URL="https://$IP:$PORT"
            else
                URL="http://$IP:$PORT"
            fi

            echo "${RED}[HIGH] Web Service Detected on $PORT"
            echo "    → Open in browser: $URL"
            echo "    → Try:"
            echo "      gobuster dir -u $URL -w common.txt"

            mkdir -p $HOST_DIR/web

            # OPTIONAL: run gobuster 
            if [ "$RUN_GOBUSTER" == "true" ]; then
            gobuster dir \
                -u $URL \
                -w $BASE_DIR/wordlists/common.txt \
                -x php,txt,html \
                -k \
                -o $HOST_DIR/web/gobuster_$PORT.txt \
                2>/dev/null
            fi

        # ================= SMB =================
        445)
            echo "${RED}[HIGH] SMB Detected"
            echo "    → Try:"
            echo "      smbclient -L //$IP -N"
            echo "      enum4linux -a $IP"

            mkdir -p $HOST_DIR/smb

            nmap --script smb-enum-shares -p 445 $IP \
                -oN $HOST_DIR/smb/smb.txt

            ;;

        # ================= SSH =================
        22)
            echo "[MEDIUM] SSH Detected"
            echo "    → Try:"
            echo "      ssh <user>@$IP"
            echo "    → Use usernames from SMB/Web"

            ;;

        # ================= FTP =================
        21)
            echo " FTP Detected"
            echo "    → Try:"
            echo "      ftp $IP"
            echo "      anonymous login"

            mkdir -p $HOST_DIR/ftp

            nmap --script ftp-anon -p 21 $IP \
                -oN $HOST_DIR/ftp/ftp.txt

            ;;

        # ================= OTHER =================
        *)
            echo " No automation for port $PORT"
            ;;

    esac

done < "$PORT_FILE"

        echo ""
        echo "[NEXT STEPS]"
        echo "1. Check SMB (445) if available"
        echo "2. Open web pages in browser"
        echo "3. Use found credentials for SSH"