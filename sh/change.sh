#!/usr/bin/env bash

# OnSongChange by MOC

# First argument is the currently playing file. Full path.

NEXT="${HOME}/.moc/next"
PLAYED="${HOME}/.moc/spelade"
LOCK="${HOME}/.moc/lock"

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

# Remove lock from podda.sh
if [[ -e "$LOCK" ]]; then
        rm "$LOCK"
fi

exit 0
