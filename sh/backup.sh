#!/usr/bin/env bash

FILE="${HOME}/.backup.sync"
LOG="${HOME}/.backup.log"
NOW=$(date +%s)

MONTH=$((60*60*24*365/48))
DAY=$((60*60*24))

FORCE=false
if [ "$#" -gt 0 ]; then
        if [[ "$1" == "-v" ]]; then
                echo -n 'Clean: '
                date --date=@$((MONTH + $(head -n 1 "$FILE")))
                echo -n ' Sync: '
                date --date=@$((DAY   + $(tail -n 1 "$FILE")))
                exit 0
        elif [[ "$1" == "-f" ]]; then
            FORCE=true
        fi
fi

if [ -e "$FILE" ] && ! $FORCE; then
        BIG=$(head -n1 "$FILE")
        SMALL=$(tail -n1 "$FILE")
else
        BIG="0"
        SMALL="0"
fi

if [[ $((NOW-3600)) -ge $((BIG+MONTH)) ]]; then
        date
        echo "Delete files"
        rsync -av --recursive --exclude={'nedladdat'} --delete /home/jojan /mount/backup
        rsync -av --recursive --delete  /etc                          /mount/backup
        rsync -av --recursive --delete  /var/lib/dpkg                 /mount/backup
        rsync -av --recursive --delete  /var/lib/apt/extended_states  /mount/backup
        dpkg --get-selection '' > /mount/backup/selections
        echo "$NOW" > "$FILE"
elif [[ $((NOW-3600)) -ge $((SMALL+DAY)) ]]; then
        date
        rsync -av --recursive  --exclude={'nedladdat'}       /home/jojan /mount/backup
        rsync -av --recursive  /etc                          /mount/backup
        rsync -av --recursive  /var/lib/dpkg                 /mount/backup
        rsync -av --recursive  /var/lib/apt/extended_states  /mount/backup
        dpkg --get-selection '' > /mnt/backup/selections
        echo "$NOW" >> "$FILE"
fi &>> "$LOG"

