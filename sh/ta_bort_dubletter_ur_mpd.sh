#!/bin/bash
command -v mpc grep mktemp > /dev/null || exit 1

UNIKA=$(mktemp)
mpc -f "%position% %file%" playlist | tac | \
        while IFS=' ' read -r pos file; do 
                if grep "$file" "$UNIKA"; then 
                        mpc del "$pos"
                else 
                        echo "$file" >> "$UNIKA"
                fi; 
        done

rm "$UNIKA"

exit 0
