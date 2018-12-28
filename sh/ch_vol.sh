#!/bin/sh

which amixer grep gawk tr > /dev/null || exit 2

arg=$(echo "$1" | tr [:upper:] [:lower:] )

#amixer  -c  0    set     Front     unmute
amixer  -q  set  Center    unmute
amixer  -q  set  Front     unmute
amixer  -q  set  LFE       unmute
amixer  -q  set  Surround  unmute

amixer  -c 0  set Front     92%
amixer  -c 0  set Surround  92%

case $arg in
    +)
        amixer -q -c 0 sset Master 1+,1+ unmute
        ;;
    -)
        amixer -q -c 0 sset Master 1-,1- unmute
        ;;
    n|normalise)

        amixer -q -c 0 set Master  75%
        ;;
    unmute|mute)
        amixer -q set Master toggle
        ;;
    *)
        if [ $# -gt 0 ]; then
            echo "Fel: Argumentet \"$1\" är otillåtet." 1>&2
        else
            echo "Fel: Behöver argument." 1>&2
        fi

        echo    "$0 [+|-|n[ormalise]|[un]mute]" 1>&2

        exit 1
        ;;
esac

${HOME}/src/vol.sh | tail -1 > ~/.volym

exit 0
