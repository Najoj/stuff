#!/bin/bash
[ -z $HOME ] && ! [ -d $HOME ] && exit 1

# Lista med namnsdagar i ordning.
FILE="${HOME}/src/namnsdagar"
# Lista med flaggdagar i oordning.
FLAG="${HOME}/src/flaggdagar"

# Året och dagen
YEAR=$(date +%Y)
DAY=$(date +%_j)

## DEBUG
#YEAR=2012   # Leap year debug
#DAY=60      # Leap year debug

# Fiffigt sätt att se om det är skottår.
if [ $( cal 2 $YEAR | grep ^2 | tail -n 1 | tr -d " " | rev | cut -c -2 ) -eq 92 ]; then
  if [ $DAY -eq 60 ]; then
        NAMES="Skottdagen"
    elif [ $DAY -gt 60 ]; then
        let DAY="$DAY-1"
        NAMES=$(head -n $DAY $FILE | tail -n 1)
    fi
else
  # Tar fram dagens namn.
  NAMES=$(head -n $DAY $FILE | tail -n 1)
fi

# Kollar om det är årsspecifk flaggdag.
DATE_THIS=$(date --date @$(echo "$(date +%s)" | bc) +"%F")
DATE_ALL=$(echo $DATE_THIS | sed s/$YEAR/DETTA_ÅR/)

# Kollar om det är datumen finns i flaggdagsfilen
PRE=""
POST=""
if grep "$DATE_THIS" "$FLAG" 1>&2 || grep "$DATE_ALL" "$FLAG" 1>&2 ; then
	PRE="\033[1;33m\033[44m ⚑ "
	POST=" \033[0m"
fi

echo -e -n "${PRE}${NAMES}${POST}"

exit 0
