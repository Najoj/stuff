#!/bin/sh

#~ while sleep 1; do
if amixer -c 0 get PCM | grep \\[off\\] > /dev/null || amixer -c 0 get Master | grep \\[off\\] > /dev/null ; then
    echo 0
else
    M=$(amixer -c 0 get Master | grep Front\ Right\: | awk '{ print $5 }' |  tr -d [:punct:])
    P=$(amixer -c 0 get PCM    | grep Front\ Right\: | awk '{ print $5 }' |  tr -d [:punct:])
    echo "( $M + $P ) / 2" | bc
fi
#~ done

exit 0

