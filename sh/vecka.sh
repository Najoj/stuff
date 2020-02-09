#!/bin/bash

# File with weeks
REDDAYS="${HOME}/src/rödadagar"
WEEKFILE="${HOME}/src/veckor"

# Day today.
TODAY=$(date +%_d | sed "s/ /0/")
# Week numbers
THISWEEK=$(date +%V)

DATE_THIS=$(date +%F)
DATE_ALL=$(echo "$DATE_THIS" | sed s/$(date +%Y)/DETTA_ÅR/)
REDDAY=false

if [ 7 == $(date +%u) ] || \
    grep "^$DATE_THIS" "$REDDAYS" &> /dev/null || \
    grep "^$DATE_ALL"  "$REDDAYS" &> /dev/null ; then
        REDDAY=true
fi

if [ "$1" = "conky" ]; then
    COLOUR=color1
    $REDDAY && COLOUR=color3

    grep -v ^\  "$WEEKFILE"                                                    \
    | grep -C 1 -m 2 "v$THISWEEK"                                              \
    | sed s/" $TODAY"/' ${'$COLOUR'}'$TODAY'${color}'/                         \
    | sed s/Rs/'${color2}'/g | sed s/Re/'${color}'/g
else #todo: if xmobar
    COLOUR="#45C913"
    $REDDAY && COLOUR="#F04545"

    echo -en '<fc=#45C913>'
    grep -m 1 "v$THISWEEK" "$WEEKFILE"                                         \
    | sed s/'Rs'/'<fc=\#7A3A3B>'/g | sed s/'Re'/'<\/fc>'/g                     \
    | sed s/' '/'<\/fc> '/ | sed s/" $TODAY"/" <fc=$COLOUR>$TODAY<\/fc>"/
fi