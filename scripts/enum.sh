#!/bin/bash

IP=$1
HOST_DIR=$2
BASE_DIR=$3

PORT_FILE="$HOST_DIR/ports.txt"

echo "[+] ENUM: $IP"

[ ! -f "$PORT_FILE" ] && exit 0

while read -r PORT; do

    [ -z "$PORT" ] && continue

    echo "[+] Port: $PORT"

    case "$PORT" in

        80|443|8080|8000|8888|5001)

            if [ "$PORT" = "443" ]; then
                URL="https://$IP:$PORT"
            else
                URL="http://$IP:$PORT"
            fi

            echo "[WEB] $URL"

            mkdir -p "$HOST_DIR/web"

            gobuster dir \
                -u "$URL" \
                -w "$BASE_DIR/wordlists/common.txt" \
                -x php,txt,html \
                -k \
                -o "$HOST_DIR/web/gobuster_$PORT.txt" \
                2>/dev/null
            ;;

        445)
            echo "[SMB] Detected"

            mkdir -p "$HOST_DIR/smb"

            nmap --script smb-enum-shares -p 445 "$IP" \
                -oN "$HOST_DIR/smb/smb.txt"
            ;;

        22)
            echo "[SSH] Detected"
            ;;

        21)
            echo "[FTP] Detected"

            mkdir -p "$HOST_DIR/ftp"

            nmap --script ftp-anon -p 21 "$IP" \
                -oN "$HOST_DIR/ftp/ftp.txt"
            ;;

        *)
            echo "[-] No automation for $PORT"
            ;;
    esac

done < "$PORT_FILE"