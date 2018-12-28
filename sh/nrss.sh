#!/bin/bash

if [[ "$1" =~ http(s)?://(www.)?(youtube|vimeo|sverigesradio|svtplay|efukt) ]]; then
    ${HOME}/src/lad.sh "$1" && beep -f 90 -l 90 || beep -f 190

elif [[ "$1" =~ http(s)?://.*.(PNG|png|jpg|gif|jpeg) ]]; then
    feh "$1"

else
    ${HOME}/src/qutebrowser/.venv/bin/python3 -m qutebrowser "$1" &> /dev/null &
fi
exit $?
