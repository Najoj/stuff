#!/bin/bash
source "${HOME}/src/utils.sh" || exit 1

SPELA_KLART="${HOME}/spela_klart"
MOCP_LOCK="${HOME}/.moc/lock"

required_programs mpc mocp sleep
required_files "$SPELA_KLART"

mpc -w pause 
mocp -U
while true; do
        O=$(mocp -Q "%file")
        C=$O
        while [[ "$O" == "$C" ]]; do
                touch "$MOCP_LOCK"
                mocp -Q "((%ts)-(%cs))" | bc | xargs ~/src/sleep 1
                C=$(mocp -Q "%file")
        done

        mocp -P
        rm -f "$MOCP_LOCK"

        for i in {1..10}; do
                echo -n "$i "
                ~/src/spela_klart || break
        done

        mpc -w pause
        mocp -U
done
