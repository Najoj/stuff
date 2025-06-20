#!/bin/bash
err() {
        echo "$@" >&2 
}

REQ=(mpc whiptail)
for r in "${REQ[@]}"; do
        if ! command -v "$r" > /dev/null; then
                err "$r is missing" 
                exit 1
        fi
done

if ! mpc -qw update; then
        err "Could not update MPD's database."
        exit 1
fi

if [ -z "$*" ]; then
        err "No input."
        exit 1
fi

RESULT=()
while IFS=$'\t' read -r nr title; do
        RESULT+=("$nr" "$title" "off")
done < <(mpc -f "%position%\\t%artist% - %title% (%album%)" playlist | \
        grep -Ei -- "$@" | sort -g | sed "s/!/\\!/g" | sed "s/?/\\?/g")

LEN=${#RESULT[@]}
# RESULT will contain three parts, thus the length divided by three will be the
# number of songs found.
LEN=$((LEN/3))
if [ $LEN -eq 0 ]; then
        err "No results."
        exit 1
fi


if [ "$LEN" -eq 1 ]; then
        FROM=$(echo "${RESULT[0]}" | cut -d\  -f 1)
else
        WHIPTAIL=(whiptail --fb --notags --radiolist --scrolltext "Välj låt med \"$@\":" 30 80 20)
        WHIPTAIL=("${WHIPTAIL[@]}" "${RESULT[@]}")

        FROM=$(exec "${WHIPTAIL[@]}" 3>&1 1>&2 2>&3)
        if [ -z "$FROM" ]; then
                err "No song chosen."
                exit 1
        fi
fi

# Position after currently playing
TO=$(($(mpc -f "%position%" current)+1))

# If moving forward a song which is located before current one, take into
# account the currently playing one
if [ "$FROM" -lt "$TO" ]; then
        ((TO-=1))
fi

mpc mv "$FROM" "$TO"

exit $?
