#!/bin/bash

# Give year as argument.
if [ -z "$1" ]; then
    YEAR=$(date +%Y)
else
    YEAR=$1
fi

################################################################################

# Is is leap year?
if date --date="29 February $YEAR" 1>&2 ; then
    FEB=29
else
    FEB=28
fi


################################################################################
SW=0   # Starting week
SD=0   # Starting day
while [ "$SW" != "02" ]; do
    (( SD += 1 ))
    SW=$(date +%V -d "$SD JAN $YEAR 00:00:00")
done

if [ $SD -gt 7 ]; then
    (( SD -= 7 ))
    SW="01"
fi

################################################################################
EW=52  # Ending week
ED=32  # Ending day
while [ "$EW" != "51" ]; do
    (( ED -= 1 ))
    EW=$(date +%V -d "$ED DEC $YEAR 00:00:00")
done

if [ $ED -lt 25 ]; then
    (( ED += 7 ))
    EW="52"
fi

################################################################################
# January
for i in $(seq -w $SD 31); do
    SEQ="$SEQ $i"
done

# Other months
for M in $FEB 31 30 31 30 31 31 30 31 30; do
    for i in $(seq -w 1 $M); do
        SEQ="$SEQ $i"
    done
done

# December
for i in $(seq -w 1 $ED); do
    SEQ="$SEQ $i"
done


################################################################################
# This is where the action happens

A=1
B=18
C=19
D=21
for i in $(seq -w $SW $EW); do
    echo -en "v$i  $(echo "$SEQ" | cut -c $A-$B | sed "s/^[ ]*//g")"
    echo -e  "Rs $(echo "$SEQ" | cut -c $C-$D | sed "s/^[ ]*//g")Re"

    ((A+=21))
    ((B+=21))
    ((C+=21))
    ((D+=21))
done

exit 0
