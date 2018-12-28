#!/bin/bash

# Give year as argument.
if [ -z $1 ]; then
    YEAR=$(date +%Y)
else
    YEAR=$1
fi

echo -e "YEAR:\t\"$YEAR\"" 1>&2
################################################################################

# Is is leap year?
if date --date="29 February $YEAR" 1>&2 ; then
    FEB=29
else
    FEB=28
fi
echo -e "FEB:\t\"$FEB\"" 1>&2


################################################################################
SW="0"   # Starting week
SD="0"   # Starting day
while [ "$SW" != "02" ]; do
    SD=$(( $SD + 1 ))
    SW=$(date +%V -d "$SD JAN $YEAR 00:00:00")
done

if [ $SD -gt 7 ]; then
    SD=$(( $SD - 7 ))
    SW="01"
fi

echo -e "SW:\t\"$SW\"" 1>&2
echo -e "SD:\t\"$SD\"" 1>&2

################################################################################
EW="52"  # Ending week
ED="32"  # Ending day
while [ "$EW" != "51" ]; do
    ED=$(( $ED - 1 ))
    EW=$(date +%V -d "$ED DEC $YEAR 00:00:00")
done

if [ $ED -lt 25 ]; then
    ED=$(( $ED + 7 ))
    EW="52"
fi

echo -e "EW:\t\"$EW\"" 1>&2
echo -e "ED:\t\"$ED\"" 1>&2

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

echo -e "\nSEQ:\t\"$SEQ\"\n" 1>&2

################################################################################
# This is where the action happens

A=1
B=17
C=18
D=20
for i in $(seq -w $SW $EW); do
    echo -en "v$i  $(echo $SEQ | cut -c $A-$B | sed "s/^[ ]*//g")"
    echo -e  "Rs $(echo $SEQ | cut -c $C-$D | sed "s/^[ ]*//g")Re"
    
    let A=$A+21
    let B=$B+21
    let C=$C+21
    let D=$D+21
done

exit 0
