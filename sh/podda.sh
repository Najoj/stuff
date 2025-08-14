#!/usr/bin/env bash
source "${HOME}/src/utils.sh" || exit 1

SPELA_KLART="${HOME}/src/spela_klart"
SLEEP="${HOME}/src/sleep"
MOCP_LOCK="${HOME}/.moc/lock"

if [[ "$1" == "--kill" ]]; then
        cleanup 0
fi

if [[ -e "$MOCP_LOCK" ]]; then
        print_warning "Skriptet körs redan"
        exit 1
fi

if ! required_programs mpc mocp sleep trap; then
        exit 1
fi
if ! required_files "$SPELA_KLART"; then
        exit 1
fi

END=10
if [[ $# == 1 ]]; then
        if [[ $1 -ge 0 ]]; then
                END=$1
        else
                print_warning "\"$1\" är ingen siffra"
        fi
fi

cleanup() {
        mocp --pause
        mpc pause
        if [[ "$MOCP_LOCK" ]]; then
                < "$MOCP_LOCK" xargs kill
                rm "$MOCP_LOCK"
        fi
        if [[ -z ${1} ]]; then
                exit "$1"
        else
                exit 1
        fi
}
trap cleanup SIGINT

MPD_TIME=$(mpc status "%currenttime%" | sed 's/:/*60+/' | bc)
if [[ "$MPD_TIME" -ge 1 ]]; then
        "$SPELA_KLART"
fi

mpc -w pause 
mocp -U || mocp -p

while true; do
        O=$(mocp -Q "%file")
        C=$O
        while [[ "$O" == "$C" ]]; do
                echo "$$" > "$MOCP_LOCK"
                WAIT=$(mocp -Q "((%ts)-(%cs)) + 1" | bc )
                WAIT=$((WAIT%900))

                $SLEEP "$WAIT"
                C=$(mocp -Q "%file")
        done

        mocp -P
        rm -f "$MOCP_LOCK"

        "$SPELA_KLART" "$END"

        mpc -w pause
        mocp -U
done
