#!/usr/bin/env bash
command -v mpc > /dev/null || exit 1

ROOT="/media/musik"
DELETE_ME="${HOME}/.mpc_delete_me"
touch "$DELETE_ME"

if [[ $# == 0 ]]; then
        mpc -f "%file%" current >> "$DELETE_ME"

elif [[ "$1" == "undo" ]]; then
        CURRENT="$(mpc -f "%file%" current)" 
        grep -vF "$CURRENT" "$DELETE_ME" > "$DELETE_ME".tmp
        #wc -l "$DELETE_ME" "$DELETE_ME".tmp
        mv "$DELETE_ME".tmp "$DELETE_ME"

elif [[ "$1" == "cleanup" ]]; then
        CURRENT=$(mpc -f "%file%" current)
        grep -Fv "$CURRENT" "$DELETE_ME" | sort -u | \
                while read -r file; do
                        echo "$file"
                        if [ "${file: -4}" == ".ogg" ]; then
                                rm "${ROOT}/${file}"
                        elif [ "${file: -5}" == ".flac" ]; then
                                mpc -f "%position% %file%" playlist |\
                                        grep -F "$file" |\
                                        tac |\
                                        while read -r pos _; do
                                                mpc del "$pos"
                                        done
                        fi

                done
                cp "$DELETE_ME" "$DELETE_ME".backup
                grep -F "$CURRENT" "$DELETE_ME".backup > "$DELETE_ME" 2> /dev/null || true
fi
