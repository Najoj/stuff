#!/usr/bin/env bash

command -v mpc 2> /dev/null || exit 1

SPELA_KLART="${HOME}/src/spela_klart"
[ -f "$SPELA_KLART" ]    || exit 1

ORIGINAL="$(mpc -f "%album%" | head -1)"
CURRENT="$ORIGINAL"

RAND=true
if mpc | grep 'random: off'; then
    RAND=false
    echo 'Not shuffled.'
fi

if [ -z "$ORIGINAL" ]; then
    echo "Inget album associerat med låten."
    RET=1
else
    mpc -f "  === %album% ===" current
    while [ "$ORIGINAL" == "$CURRENT" ]; do
        mpc -f " %track%. %artist% - %title% (%time%)" random off | head -1
        $SPELA_KLART
        CURRENT="$(mpc -f "%album%" | head -1)"
    done

    if $RAND; then
        mpc random on
        mpc next
        if [ "$1" = "-p" ]; then
            mpc pause
        fi
    fi
    RET=0
fi

exit $RET
