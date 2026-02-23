#!/usr/bin/env bash
source "${HOME}/src/utils.sh"

# Not before December
DAY=$(date +%_d)
MONTH=$(date +%_m)
if [[ $MONTH -lt 12 ]]; then
        echo "Inte ens december, dumsnut!"
        exit 1
elif [[ $DAY -gt 24 ]]; then
        echo "Julafton har redan varit, dumbom!"
        exit 1
fi

# Song frequency changes
FREQ_L=12
FREQ_H=6
if [[ $DAY -le 12 ]]; then
        FREQ=$FREQ_L
elif [[ $DAY -le 24 ]]; then
        FREQ=$FREQ_H
fi

# List of directories relative mpd's music_directory.
JULLISTA="/media/musik/.spellistor/jullista.m3u"

if ! required_files "$JULLISTA"; then
        exit 1
fi
if ! required_programs mpc flock grep sort shuf read spela_klart; then
        exit 1
fi

TEMP=$(mktemp)
sort -u "$JULLISTA" > "$TEMP"
mv -vn "$TEMP" "$JULLISTA"

MPC_LOCK="${HOME}/.mpc_lock"
N=$(sort -u "$JULLISTA" | sort -u | wc -l)
I=0
sort -u "$JULLISTA" | shuf | while read -r file; do
        ((I++))
        (flock -x 9 
        printf "\r%d / %d. %s" "$I" "$N" "$file"
        if [[ -e "/media/musik/$file" ]]; then
                mpc insert "$file"
                spela_klart
                POS=$(mpc -f "%position%" current) 
                spela_klart
                mpc del "$POS"
        else 
                grep -v "$file" "$JULLISTA" > "$TEMP" && mv "$TEMP" "$JULLISTA"
                >&2 echo -e "\nTog bort $file"
        fi) 9> "$MPC_LOCK"

        if [[ -e "/media/musik/$file" ]]; then
                for ((i=0; i<FREQ; i++)); do
                        spela_klart && echo -n .
                done
                echo ""
        fi
        DAY=$(date +%_d)
        if [[ $DAY -lt 12 ]]; then
                FREQ=$FREQ_L
        elif [[ $DAY -le 24 ]]; then
                FREQ=$FREQ_H
        else
                echo "Julafton är över för denna gång."
                exit 1
        fi
done

echo "Slut!"
