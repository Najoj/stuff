#!/usr/bin/env bash

# Re-write of julmusik.sh without flock
# shellcheck disable=SC1091
source "${HOME}/src/utils.sh"

# Not before December
DAY=$(date +%_d)
MONTH=$(date +%_m)
if [[ $MONTH -lt 12 ]]; then
        echo "Inte ens december, dumsnut!"
        exit 1
elif [[ $DAY -gt 24 ]]; then
        echo "Julafton har redan varit, dumbom!"
fi

# Song frequency changes
FREQ_L=10   # low
FREQ_M=5    # midd
FREQ_H=15   # high

if [[ $DAY -le 12 ]]; then
        FREQ=$FREQ_L
elif [[ $DAY -le 24 ]]; then
        FREQ=$FREQ_M
else
        FREQ=$FREQ_H
fi

# List of directories relative mpd's music_directory.
JULLISTA="/media/musik/.spellistor/jullista.m3u"
RMPL="${HOME}/.mpc_delete_me"

if ! required_files "$JULLISTA" "$RMPL"; then
        exit 1
fi
if ! required_programs mpc spela_klart grep sort shuf read; then
        exit 1
fi

TEMP=$(mktemp)
sort -u "$JULLISTA" > "$TEMP"
mv -vn "$TEMP" "$JULLISTA"

N=$(sort -u "$JULLISTA" | sort -u | wc -l)
I=0
sort -u "$JULLISTA" | shuf | while read -r file; do
        ((I++))
        printf "%d / %d. %s\n" "$I" "$N" "$file"
        if [[ -e "/media/musik/$file" ]]; then
                mpc insert "$file"
                spela_klart "$FREQ"
                echo "#${file}" >> "$RMPL"
                echo ""
        fi
        DAY=$(date +%_d)
        if [[ $DAY -lt 12 ]]; then
                FREQ=$FREQ_L
        elif [[ $DAY -le 24 ]]; then
                FREQ=$FREQ_M
        elif [[ $DAY -le 31 ]]; then
                FREQ=$FREQ_H
        else
                echo "Gott nytt år!"
                exit 1
        fi
done

echo "Slut!"
