#!/usr/bin/env bash

! [ -d "$1" ] && echo "Give mountpoint" && exit 1

DIR="$1"
MUS="/media/musik/"
ART='(Offspring|Bad\ Religion)'
cd "$MUS"

find . -name \*\.flac | grep -E "$ARTIST"
