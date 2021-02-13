#!/bin/bash
UNIKA=$(mktemp)

mpc -f "%position% %file%" playlist | \
        while IFS=' ' read -r pos file; do 
                if grep "$file" "$UNIKA"; then 
                        mpc del "$pos"
                else 
                        echo "$file" >> "$UNIKA"
                fi; 
        done

rm "$UNIKA"
