#!/bin/bash

# OnSongChange by MOC

# First argument is the currently playing file. Full path.

NEXT="${HOME}/.moc/next"
PLAYED="${HOME}/.moc/spelade"

current="$1"
previous=$(head -1 "${NEXT}")

if [[ -f "$previous" ]]; then
        mkdir -p "$PLAYED"
        mv -v "$previous" "$PLAYED"
fi
echo "$current" > "${NEXT}"

# Stop
STOP="${HOME}/.moc/stopp"
if [[ -e "$STOP" ]]; then
        mocp --pause
fi

exit 0
