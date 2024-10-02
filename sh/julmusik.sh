#!/bin/bash
source "${HOME}/src/utils.sh"

# List of directories relative mpd's music_directory.
JULLISTA="/media/musik/.spellistor/jullista.m3u"
SPELA_KLART="${HOME}/src/spela_klart"

if ! required_files "$JULLISTA" "$SPELA_KLART"; then
        exit 1
fi

FREQ_L=10
FREQ_H=5

DAY=$(date +%d)
MONTH=$(date +%m)

if [[ $MONTH -lt 12 ]]; then
        echo "Inte ens december, dumsnut!"
        exit 1
fi
if [[ $DAY -lt 12 ]]; then
        FREQ=$FREQ_L
elif [[ $DAY -lt 24 ]]; then
        FREQ=$FREQ_H
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

reqs=(mpc flock grep sort shuf read)
for req in "${reqs[@]}"; do
        if ! command -v "$req" &> /dev/null; then
                >&2 echo "Programmet finns inte: $req"
                exit 1
        fi
done

MPC_LOCK="/home/jojan/.mpc_lock"
N=$(sort -u "$JULLISTA" | sort -u | wc -l)
I=0
sort -u "$JULLISTA" | shuf | while read -r file; do
        ((I++))
        (flock -x 9 
        echo -e "\r$I / $N. $file"
        if [[ -e "/media/musik/$file" ]]; then
                mpc insert "$file"
                "$SPELA_KLART"
                POS=$(mpc -f "%position%" current) 
                "$SPELA_KLART"
                mpc del "$POS"
        else 
                TEMP=$(mktemp)
                grep -v "$file" "$JULLISTA" > "$TEMP" && mv "$TEMP" "$JULLISTA"
                >&2 echo "Tog bort $file"
        fi) 9> "$MPC_LOCK"

        if [[ -e "/media/musik/$file" ]]; then
                for ((i=0; i<FREQ; i++)); do
                        "$SPELA_KLART" && echo -n .
                done
        fi
        DAY=$(date +%d)
        if [[ $DAY -lt 12 ]]; then
                FREQ=$FREQ_L
        elif [[ $DAY -lt 24 ]]; then
                FREQ=$FREQ_H
        else
                echo "Julafton har redan varit, dumbom!"
                exit 1
        fi
done

echo "Slut!"
