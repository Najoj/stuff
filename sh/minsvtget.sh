#!/bin/bash

URL=$1
TITLE="svtget" # ÄNDRA INTE
echo -e '\033]2;'$TITLE'\007'

TMP=".svtplay-dl-"
R=1
while ! ls -d ${TMP}* 2> /dev/null | wc -l | grep -E ^"[0-3]"$; do
        echo -en '\r'
        date +%T | tr -d '\n'

        R=$((($RANDOM % 60 + $R) % 300))
        echo -en "  Väntar $R sekunder..."
        sleep $R
done

SHA=$(echo $URL | sha256sum | awk '{ print $1 }' )
TMP="${TMP}${SHA}"

if [ -d "$TMP" ]; then
    echo "$(date +%T)  Mappen \"$TMP\" finns redan."
    sleep 10
    exit 1
fi

mkdir -p "$TMP" && cd "$TMP"

youtube-dl "${URL}"
mv -nv *.* ..
cd .. && rmdir "$TMP"

echo "$(date +%T)  Klar."
sleep 10
