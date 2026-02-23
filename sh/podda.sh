#!/usr/bin/env bash
source "${HOME}/src/utils.sh" || exit 1

SLEEP="${HOME}/src/sleep"
MOCP_LOCK="${HOME}/.moc/lock"

function _cleanup() {
        MPD_STATE="$(mpc status "%state%")"
        MPD_PAUSE="paused"
        mocp --pause
        if [[ "$MPD_STATE" == "$MPD_PAUSE" ]]; then
                mpc pause
        fi
        if [[ -e "$MOCP_LOCK" ]]; then
                < "$MOCP_LOCK" xargs kill
                rm -f "$MOCP_LOCK"
        fi
        if [[ -z "${1}" ]]; then
                exit 1
        else
                exit "$1"
        fi
}
trap _cleanup SIGINT


if [[ "$1" == "--kill" ]]; then
        _cleanup 0
fi

if [[ "$1" == "--force" ]]; then
        rm -f "$MOCP_LOCK"
fi

if [[ -e "$MOCP_LOCK" ]]; then
        print_warning "Skriptet körs redan"
        exit 1
fi

if ! required_programs mpc mocp sleep trap spela_klart; then
        exit 1
fi

END=10
if [[ $# == 1 ]]; then
        if [[ $1 -ge 0 ]] && is_int "$1"; then
                END=$1
        else
                print_warning "\"$1\" är ingen siffra"
        fi
fi


MPD_TIME=$(mpc status "%currenttime%" | sed 's/:/*60+/' | bc)
if [[ "$MPD_TIME" -ge 1 ]]; then
        spela_klart
fi

mpc -w pause 
mocp -U || mocp -p

while true; do
        O=$(mocp -Q "%file")
        C=$O
        while [[ "$O" == "$C" ]]; do
                echo "$$" > "$MOCP_LOCK"
                WAIT=$(mocp -Q "((%ts)-(%cs))" | bc )
                STATE="$(mocp -Q"%state")"

                if [[ "${STATE}" == "PASUE" ]] && [[ "$WAIT" -le 60 ]]; then
                        WAIT=60
                else
                        WAIT=$((WAIT%900))
                fi
                
                # Sleep and wait 1 second extra
                $SLEEP "$WAIT" 1
                C=$(mocp -Q "%file")
        done

        mocp -P
        rm -f "$MOCP_LOCK"
        
        for((i=0;i<END;i++)) {
                printf "\r%d / %d " "$i" "$END"
                spela_klart
        }
        echo ""

        mpc -w pause
        mocp -U
done
