#!/bin/bash

required=(mpc flock)
for req in required; do
        if ! which "$req" &> /dev/nul; then
                &> echo 


FIL="$(mpc -f "%file%"     current)"
POS="$(mpc -f "%position%" current)"

TYP="$(echo "$FIL" | rev | cut -d \. -f 1 | rev)"

if [ "$TYP" == "flac" ]; then
        del_pos=true
else
        del_file=true
fi

if [ "$1" == "rev" ]; then
        reverse=true
else
        reverse=false
fi



T=.osorterat/Masses - Left Behind.ogg; ~/src/spela_klart && sleep 1 && flock -x /home/jojan/.mpc_lock -c rm -v -- "/media/musik/ogg" 

T=.osorterat/Masses - Left Behind.ogg; ~/src/spela_klart && sleep 1 && flock -x /home/jojan/.mpc_lock -c rm -v -- "/media/musik/ogg" 
