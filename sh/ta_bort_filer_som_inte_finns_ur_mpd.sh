#!/usr/bin/env bash
command -v mpc grep mktemp > /dev/null || exit 1
cd /media/musik || exit 1
mpc -f "%position% %file%" playlist | tac | \
        while IFS=' ' read -r pos file; do 
                if ! [ -e "$file" ]; then
                        echo "Filen finns inte:  $file"
                        mpc del "$pos"
                elif grep -F "$file" "$UNIKA"; then 
                        echo "Filen fler gånger: $file"
                        mpc del "$pos"
                else 
                        echo "$file" >> "$UNIKA"
                fi; 
        done


exit 0
