#!/bin/bash

IP=$1
HOST_DIR=$2
BASE_DIR=$3

PORT_FILE="$HOST_DIR/ports.txt"

while read -r PORT; do

    echo "[DEBUG] Processing port: $PORT"

    case $PORT in

        80|8080|5001)
            URL="http://$IP:$PORT"
            ;;

        443)
            URL="https://$IP:$PORT"
            ;;

        445)
            echo "[+] SMB detected on $IP"
            
            mkdir -p $HOST_DIR/smb
            
            nmap --script smb-enum-shares -p 445 $IP \
                -oN $HOST_DIR/smb/smb.txt
            
            continue
            ;;

        21)
            echo "[+] FTP detected on $IP"
            
            mkdir -p $HOST_DIR/ftp
            
            nmap --script ftp-anon -p 21 $IP \
                -oN $HOST_DIR/ftp/ftp.txt
            
            continue
            ;;

        *)
            echo "[-] No automation for port $PORT"
            continue
            ;;

    esac

    # Web handling (only runs if URL is set)
    echo "[+] Web detected on $URL"

    mkdir -p $HOST_DIR/web

    gobuster dir \
        -u $URL \
        -w $BASE_DIR/wordlists/common.txt \
        -x php,txt,html \
        -k \
        -o $HOST_DIR/web/gobuster_$PORT.txt \
        2>&1 | tee $HOST_DIR/web/debug_$PORT.log

done < "$PORT_FILE"