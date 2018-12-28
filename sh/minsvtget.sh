#!/bin/bash

TITLE="svtget"
echo -e '\033]2;'$TITLE'\007'

URL=$1

R=1
while ! ps a | grep '/svtplay-dl' | wc -l | grep -E ^"[0123]"$ ; do
        echo -en '\r'
        date +%T | tr -d '\n'
        
        R=$((($RANDOM % 60 + $R) % 600))
        echo -en "  Väntar $R sekunder..."
        sleep $R
done

RAN=$(echo $URL | sha256sum | awk '{ print $1 }' )
TMP=".svtplay-dl-$RAN"

if [ -d "$TMP" ]; then
    echo "$(date +%T)  Mappen \"$TMP\" finns redan."
    sleep 10
    exit 1
fi

mkdir -p "$TMP" && cd "$TMP"

svtplay-dl -r "${URL}" || youtube-dl -c "${URL}"
mv -nv *.* ..
cd .. && rmdir "$TMP"

echo "$(date +%T)  Klar."
sleep 10
