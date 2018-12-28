#!/bin/sh

#~ while sleep 1; do
if amixer -c 0 get Master | grep \\[off\\] > /dev/null ; then
    echo 0
else
    amixer -c 0 get Master | grep Mono\: | awk '{ print $3 }' |  tr -d [:punct:]
fi
#~ done

exit 0

