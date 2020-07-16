#!/bin/bash

err() {
    echo "$@" >&2
}

if [ -z "$*" ]; then
    err "No input."
    exit 1
fi

LIM=20
RESULT=$(mpc -f "%position% \"%artist% - %title% (%album%)\" off  " playlist | grep -Ei "$@" | tail -n $LIM)
WHIPTAIL="whiptail --fb --notags --radiolist \"Vilken menar du?\" 30 80 20 $RESULT"
LEN=$(echo "${RESULT}" | grep -cv ^$)

if [ "$LEN" -eq 0 ]; then
    err "No results."
    exit 1
elif [ "$LEN" -eq 1 ]; then
    echo "$RESULT" | cut -d \" -f 2
    FROM=$(echo "$RESULT" | cut -d\  -f 1)
else
    FROM=$(eval "$WHIPTAIL" 3>&1 1>&2 2>&3)
    if [ -z "$FROM" ]; then
        err "No file chosen."
        exit 1
    fi
fi

TO=$(($(mpc -f "%position%" current)+1))

if [ "$FROM" -lt "$TO" ]; then
    TO=$((TO+1))
fi

mpc mv "$FROM" "$TO"

exit

