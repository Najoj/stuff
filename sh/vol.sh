#!/bin/sh

if amixer get Master | grep "\\[off\\]" > /dev/null ; then
    echo 0
else
    amixer get Master | tail -n1 | awk '{ print $5 }' |  tr -d '[:punct:]'
fi

exit 0

