#!/bin/sh

#~ while sleep 1; do
if amixer -c 0 get Master | grep "\\[off\\]" > /dev/null ; then
    echo 0
else
    amixer -c 0 get Master | grep Front\ Left: | awk '{ print $4 }' |  tr -d "[:punct:]"
fi
#~ done

exit 0

