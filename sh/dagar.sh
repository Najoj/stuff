#!/bin/bash

if [ $# -lt 1 ]; then
        DAT="1988-05-04 01:00"
else
        DAT="${*}"
fi

IDAG=$(date               +%s)
FDAG=$(date --date="$DAT" +%s)

DAGAR=$(( (IDAG-FDAG) / (60*60*24) ))

if factor "$DAGAR" | wc -w | grep ^2$ > /dev/null ; then
        echo -en '\033[35m\033[40m' ${DAGAR} '\033[0m'
elif echo "$DAGAR" | grep 00$ > /dev/null ; then
        echo -en '\033[36m\033[40m' ${DAGAR} '\033[0m'
else
        echo -n ${DAGAR}
fi

echo -n " dagar"
