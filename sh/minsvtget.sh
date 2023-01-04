#!/bin/bash

SVTPLAYDL="${HOME}/src/svtplay-dl/svtplay-dl"

WD=$(pwd)
URL=$1
if [ -z "${URL}" ]; then
        echo "No URL argument"
        exit 2
fi

TITLE="svtget" # ÄNDRA INTE
echo -e '\033]2;'$TITLE'\007'

TMP=".svtplay-dl-"

# Remove stuck folders
AGO=$(date --date="12 hours ago" +%s)
find ${TMP}* -maxdepth 1 -type d 2> /dev/null | while read -r directory; do
        NOW=$(stat -c "%Z" "$directory")
        if [ "$NOW" -lt "$AGO" ]; then
                echo "Tar bort $directory"
                rm -rf "$directory"
        fi
done

# See if there are plenty of dowloads already running
R=1
until find ${TMP}* -maxdepth 1 -type d 2> /dev/null | wc -l | grep -E ^"[0-1]"$; do
        echo -en '\r'
        date +%T | tr -d '\n'

        R=$(((RANDOM % 60 + R) % 300))
        echo -en "  Väntar $R sekunder..."
        sleep $R
done

SHA=$(echo "$URL" | sha256sum | awk '{ print $1 }' )
TMP_SHA="${TMP}${SHA}"

# See if folder already exists
if [ -d "$TMP_SHA" ]; then
        echo "$(date +%T)  Mappen \"$TMP_SHA\" finns redan."
        sleep 10
        exit 1
fi

mkdir -p "$TMP_SHA" 
cd "$TMP_SHA" || exit 1

# Dowload with 3 retries
R=0
L=3
until "${SVTPLAYDL}" "${URL}" || [ $R -lt $L ]; do
        echo "$R/$L"
        sleep 5
        R=$((R+1))
done

# Move files and remove files
if [ $R -lt $L ]; then
        mv -nv -- *.* "$WD"
        cd .. && rmdir "$TMP_SHA"
else
        cd .. && rm -rf "$TMP_SHA"
fi

echo "$(date +%T)  Klar."
sleep 10
