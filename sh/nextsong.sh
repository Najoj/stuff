#!/bin/bash

err() {
    echo "$@" >&2
}

if [ -z "$*" ]; then
    err "No input."
    exit 1
fi

LIM=20
RESULT=$(mpc -f "%position% \"%artist% - %title% (%album%)\" off  " playlist | grep -Ei "$@" | shuf | tail -n $LIM )
LEN=$(echo "${RESULT}" | grep -cv ^$)

RESULT=$(echo $RESULT | tr '\n' ' ')
WHIPTAIL="whiptail --fb --notags --radiolist \"Vilken menar du?\" 30 80 20 $RESULT"

if [ "$LEN" -eq 0 ]; then
    err "No results."
    exit 1
elif [ "$LEN" -eq 1 ]; then
    FROM=$(echo "$RESULT" | cut -d\  -f 1)
else
    FROM=$($WHIPTAIL 3>&1 1>&2 2>&3)
    echo FROM $FROM
    if [ -z $FROM ]; then
        err "No file chosen."
        exit 1
    fi
fi

TO=$(($(mpc -f "%position%" current)+1))

if [ $FROM -lt $TO ]; then
    TO=$((TO+1))
fi

mpc mv "$FROM" "$TO"

exit

