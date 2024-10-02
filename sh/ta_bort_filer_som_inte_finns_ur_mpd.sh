#!/bin/bash

command -v mpc > /dev/null || exit 1

cd /media/musik || exit 1
mpc -f "%position% %file%" playlist | tac | \
        while IFS=' ' read -r pos file; do 
                if ! [ -e "$file" ]; then
                        mpc del "$pos"
                fi; 
        done


exit 0
