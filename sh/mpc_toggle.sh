#!/usr/bin/env bash

MOCP_LOCK="${HOME}/.moc/lock"
if ! [[ -e "$MOCP_LOCK" ]]; then
        # MOCP script is not running
        mpc toggle
        exit 0
fi

# Complex code

source "${HOME}/src/utils.sh" || exit 1

if ! required_programs mpc mocp ; then
        exit 1
fi

MOCP_PAUSE="PAUSE"
MPD_PAUSE="paused"

MOCP_STATE="$(mocp -Q%state)"
MPD_STATE="$(mpc status "%state%")"

MOCP_TIME="$(mocp -Q%cs)"
MPD_TIME="$(mpc -f "%time%" current | sed 's/:/*60+/' | bc)"

if [ "$MPD_STATE" == "$MPD_PAUSE" ] && [ "$MOCP_STATE" == "$MOCP_PAUSE" ]; then
        # Both are paused. See which one was probably playing.
        if [ "$MOCP_TIME" -gt 2 ]; then
                mocp --unpause
        elif [ "$MPD_TIME" -gt 2 ]; then
                mpc toggle
        else
                mocp --unpause
        fi
elif [ "$MOCP_STATE" == "$MOCP_PAUSE" ]; then
        # MOCP is paused, toggle MPD
        mpc toggle
elif [ "$MPD_STATE" == "$MPD_PAUSE" ]; then
        # MPD is paused. 
        mocp --pause
else
        # Neither is paused.
        mpc pause
fi
