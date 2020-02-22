#!/bin/sh

command -v amixer grep gawk tr > /dev/null || exit 2

arg=$(echo "$1" | tr "[:upper:]" "[:lower:]" )

alias amixer='amixer -c0'

#amixer  sset  Master   unmute
#amixer  sset  Capture  unmute

case $arg in
    +)
        amixer sset Master 1+,1+ unmute
        ;;
    -)
        amixer sset Master 1-,1- unmute
        ;;
    n|normalise)

        amixer set Master  50%
        ;;
    unmute|mute)
        amixer set Master toggle
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

"${HOME}"/src/vol.sh | tail -1 > ~/.volym

exit 0
