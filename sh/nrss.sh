#!/bin/bash

if [[ "$1" =~ http(s)?://(www.)?(youtube|vimeo|sverigesradio|svtplay|efukt) ]]; then
        "${HOME}/src/lad.sh" "$1"

elif [[ "$1" =~ http(s)?://.*.(PNG|png|jpg|gif|jpeg) ]]; then
        feh "$1"

else
        firefox "$1" &> /dev/null &
fi
exit $?
