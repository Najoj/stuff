#!/bin/bash

URL=$1
TITLE="svtget" # ÄNDRA INTE
echo -e '\033]2;'$TITLE'\007'

TMP=".svtplay-dl-"

# Remove stuck folders
AGO=$(date --date="24 hours ago" +%s)
find ${TMP}* -maxdepth 1 -type d 2> /dev/null | while read -r directory; do
        NOW=$(stat -c "%Z" "$directory")
        if [ "$NOW" -lt "$AGO" ]; then
                echo "Tar bort $directory"
                rm -rf "$directory"
        fi
done

# See if there are plenty of dowloads already running
R=1
while ! find ${TMP}* -maxdepth 1 -type d 2> /dev/null | wc -l | grep -E ^"[0-2]"$; do
        echo -en '\r'
        date +%T | tr -d '\n'

        R=$(((RANDOM % 60 + R) % 300))
        echo -en "  Väntar $R sekunder..."
        sleep $R
done

SHA=$(echo "$URL" | sha256sum | awk '{ print $1 }' )
TMP="${TMP}${SHA}"

# See if folder already exists
if [ -d "$TMP" ]; then
        echo "$(date +%T)  Mappen \"$TMP\" finns redan."
        sleep 10
        exit 1
fi

mkdir -p "$TMP" 
cd "$TMP" || exit 1

# Dowload with 3 retries
R=0
while ! youtube-dl "${URL}" && [ $R -lt 3 ]; do
        sleep 5
        R=$((R+1))
done

# Move files and remove files
if [ $R -lt 3 ]; then
        mv -nv -- *.* ..
        cd .. && rmdir "$TMP"
else
        cd .. && rm -rf "$TMP"
fi

echo "$(date +%T)  Klar."
sleep 10
