#!/bin/bash

# Lista med namnsdagar i ordning.
FILE="${HOME}/src/namnsdagar"
# Lista med flaggdagar i oordning.
FLAG="${HOME}/src/flaggdagar"

# Option to add days ahead
DAYS_AHEAD=0
if [ -n "$1" ]; then
    DAYS_AHEAD=$1
fi

# Året och dagen
YEAR=$(date +%Y)
DAY=$(date +%_j --date="$DAYS_AHEAD days")

## DEBUG
#YEAR=2012   # Leap year debug
#DAY=60      # Leap year debug

# Tar fram dagens namn.
NAMES=$( head -n"$DAY" "$FILE" | tail -1)
# Fiffigt sätt att se om det är skottår.
if date --date="February 29, $YEAR" &> /dev/null; then
    if [ "$DAY" -eq 60 ]; then
        NAMES="Skottdagen"
    elif [ "$DAY" -gt 60 ]; then
            DAY=$((DAY-1))
        NAMES=$(head -n "$DAY" "$FILE" | tail -n 1)
    fi
fi

# Kollar om det är flaggdag.
DATE_THIS=$(date +"%F" --date="$DAYS_AHEAD days")
DATE_ALL=${DATE_THIS//$YEAR/DETTA_ÅR}

# Kollar om det är datumen finns i flaggdagsfilen
PRE=""
POST=""
if ! grep -q "$YEAR" "$FLAG"; then
        echo "Uppdatera ${FLAG}!"
fi
if grep -q "$DATE_THIS" "$FLAG" || grep -q "$DATE_ALL" "$FLAG" ; then
    PRE="\\033[1;33m\\033[44m ⚑ "
    POST=" \\033[0m"
fi

if ! [[ "${NAMES}" =~ dag(en)? ]]; then
        PRE="$PRE Namnsdag: "
fi

echo -e -n "${PRE}${NAMES}${POST}"

exit 0
