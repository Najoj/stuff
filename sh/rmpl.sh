#!/bin/bash

SPELA_KLART="/home/jojan/src/spela_klart"
ROOT="/media/musik"

_delete_file() {
        # Deletes file from hard drive
        echo -n "rm ${1}... "
        "$SPELA_KLART"
        flock -x "$MPC_LOCK" -c "rm -f -- \"$1\""
        echo "done!"
}
_remove_file() {
        # Removes file from playlist
        echo -n "mpc del ${1}... "
        flock -x "$MPC_LOCK" -c "$SPELA_KLART && mpc del \"$1\""
        echo "done!"
}



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

inverted=false
if [ "$1" = "-f" ] || [ "$1" = "-i" ]; then
        inverted=true
fi

# file to remove
file_name="$ROOT/$(mpc -f "%file%" current)"
ogg_file=${file_name%ogg}ogg
# file position in list
file_pos=$(mpc -f "%position%" current)

mpc -f "%artist% - %title%" current
if $inverted; then
        if [ -e "${file_name}" ]; then
                _remove_file "$file_pos"
        else
                _delete_file "$file_name"

        fi
else
        # Only remove ogg files
        if [ -e "${ogg_file}" ]; then
                _delete_file "$file_name"
        else
                _remove_file "$file_pos"
        fi
fi

