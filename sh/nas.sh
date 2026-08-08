#!/usr/bin/env bash
ADDR=192.168.1.183

FILE="${HOME}/.nas.sync"
LOG="${HOME}/.nas.log"
NOW=$(date +%s)

MONTH=$((60*60*24*365/12))
DAY=$((60*60*24))

FORCE=false
RESTORE=false
if [ "$#" -gt 0 ]; then
        if [[ "$1" == "-v" ]]; then
                echo -n 'Clean: '
                date --date=@$((MONTH + $(head -n 1 "$FILE")))
                echo -n ' Sync: '
                date --date=@$((DAY   + $(tail -n 1 "$FILE")))
                exit 0
        elif [[ "$1" == "-f" ]]; then
            FORCE=true
        elif [[ "$1" == "-ro" ]]; then
            RESTORE=true
            OSORT=true
        elif [[ "$1" == "-r" ]]; then
            RESTORE=true
            OSORT=false
        fi
fi

if [ -e "$FILE" ] && ! $FORCE; then
        BIG=$(head -n1 "$FILE")
        SMALL=$(tail -n1 "$FILE")
else
        ((BIG=0))
        ((SMALL=0))
fi

if curl https://am.i.mullvad.net/connected | grep -q 'You are not'; then
        echo 'Not connected to Mullvad'
        RSYNC=rsync
        PING=ping
else
        echo 'Connected to Mullvad'
        RSYNC="mullvad-exclude rsync"
        PING="mullvad-exclude ping"
fi

if $RESTORE; then
        if $OSORT; then
                $RSYNC -az -e "ssh -i ${HOME}/.ssh/truenas-jojan.private" --recursive --delete "${ADDR}:/mnt/default/.osorterat" /media/musik/.osorterat
        else
                $RSYNC -az -e "ssh -i ${HOME}/.ssh/truenas-jojan.private" --recursive --delete "${ADDR}:/mnt/default/" /media/musik "${HOME}/bilder"
        fi

elif [[ $((NOW-3600)) -ge $((SMALL+DAY)) ]]; then
        date

        if ! $PING -c2 "$ADDR"; then
                exit 1
        fi

        if [[ $((NOW-3600)) -ge $((BIG+MONTH)) ]]; then
                echo "Delete files"
                $RSYNC -az -e "ssh -i ${HOME}/.ssh/truenas-jojan.private" --recursive --delete /media/musik "${HOME}/bilder" "${ADDR}:/mnt/default"
                echo "$NOW" > "$FILE"
        elif [[ $((NOW-3600)) -ge $((SMALL+DAY)) ]]; then
                $RSYNC -az -e "ssh -i ${HOME}/.ssh/truenas-jojan.private" --recursive /media/musik "${HOME}/bilder" "${ADDR}:/mnt/default"
                echo "$NOW" >> "$FILE"
        fi
fi | tee -a "$LOG"
