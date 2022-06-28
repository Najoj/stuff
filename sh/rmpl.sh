#!/bin/bash

SPELA_KLART="/home/jojan/src/spela_klart"
ROOT="/media/musik"

reqs=("$SPELA_KLART" "$MPC_LOCK" "$ROOT")
for req in "${reqs[@]}"; do
        if ! [[ -e "$req" ]]; then
                >&2 echo "Required file does not exist: $req"
                exit 1
        fi
done

reqs=(mpc flock rm)
for req in "${reqs[@]}"; do
        if ! command -v "$req" &> /dev/null; then
                >&2 echo "Required program not found: $req"
                exit 1
        fi
done

if [[ "$1" -eq "-f" ]]; then
        force=true
fi

# update playlist quietly
if ! mpc -qw update; then
        >&2 echo "Issue updating mpd playlist"
        exit 1
fi

# file to remove
file_name=$(mpc -f "%file%" current)
# file position in list
file_pos=$(mpc -f "%position%" current)

if [ $force ] || [ -e "${file_name%ogg}ogg" ]; then
        "$SPELA_KLART"
        flock -x "$MPC_LOCK" -c "rm \"$ROOT\"/\"$file_name\""
else
        flock -x "$MPC_LOCK" -c "$SPELA_KLART && mpc del \"$file_pos\""
fi

