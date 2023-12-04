#!/bin/bash

# List of directories relative mpd's music_directory.
JULLISTA="/media/musik/.spellistor/jullista.m3u"
SPELA_KLART="${HOME}/src/spela_klart"

MONTH=$(date +%m)
if [[ $MONTH -lt 12 ]]; then
        echo "Inte ens december, dumsnut!"
        exit 1
fi


DAY=$(date +%d)
if [[ $DAY -lt 12 ]]; then
        FREQ=40
elif [[ $DAY -lt 24 ]]; then
        FREQ=20
else
        echo "Julafton har redan varit, dumbom!"
        exit 1
fi

reqs=("$JULLISTA" "$SPELA_KLART")
for req in "${reqs[@]}"; do
        if ! [[ -e "$req" ]]; then
                >&2 echo "Filen finns inte: $req"
                exit 1
        fi
done

reqs=(mpc flock sed sort shuf read)
for req in "${reqs[@]}"; do
        if ! command -v "$req" &> /dev/null; then
                >&2 echo "Programmet finns inte: $req"
                exit 1
        fi
done

MPC_LOCK="/home/jojan/.mpc_lock"
N=$(sort -u "$JULLISTA" | wc -l)
I=0
sort -u "$JULLISTA" | shuf | while read -r file; do
        ((I++))
        (flock -x 9 
        echo "$I / $N. $file"
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

        if [[ -e "/media/musik/$file" ]]; then
                for ((i=0; i<FREQ; i++)); do
                        "$SPELA_KLART" && echo -n .
                done
        fi
done

echo "Slut!"
