#!/bin/bash

# List of directories relative mpd's music_directory.
JULLISTA="/media/musik/.spellistor/jullista.m3u"
SPELA_KLART="${HOME}/src/spela_klart"
FREQ=20

reqs=("$JULLISTA" "$SPELA_KLART")
for req in "${reqs[@]}"; do
        if ! [[ -e "$req" ]]; then
                >&2 echo "Filen finns inte: $req"
                exit 1
        fi
done

reqs=(mpc flock)
for req in "${reqs[@]}"; do
        if ! command -v "$req" &> /dev/null; then
                >&2 echo "Programmet finns inte: $req"
                exit 1
        fi
done

MPC_LOCK="/home/jojan/.mpc_lock"
sort -u "$JULLISTA" | shuf | while read -r file; do
        (flock -x 9 
        echo "$file"
        if [[ -e "/media/musik/$file" ]]; then
                mpc insert "$file"
                "$SPELA_KLART"
                POS=$(mpc -f "%position%" current) 
                "$SPELA_KLART"
                mpc del "$POS"
        else 
                >&2 echo "Tog bort $file"
                sed -i "/$file/d" "$JULLISTA"
        fi) 9> "$MPC_LOCK"

        for ((i=0; i<FREQ; i++)); do
                "$SPELA_KLART"
        done
done

echo "Slut!"
