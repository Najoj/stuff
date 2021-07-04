#!/bin/bash
# Move the argument number of songs from the end of current MPD playlist to
# random position. If no argument, move 10 songs.

if [ $# -eq 1 ] && test "$1" -eq "$1" && [ "$1" -ge 0 ]; then
    N=$1
else
    N=10
fi

mpc -wq update

LEN=$(mpc playlist | wc -l)

BEFORE=$(mpc -f "%position%" current)
seq $N | while read -r; do
        CUR=$(($(mpc -f %position% current)+1))
        NEW=$((RANDOM % (LEN-CUR-N) + CUR))
        mpc mv "${LEN}" "${NEW}"
done
AFTER=$(mpc -f "%position%" current)

# Just a notice for the user if the current song position has been changed.
if ! [ "$BEFORE" -eq "$AFTER" ]; then
        echo "before $BEFORE != after $AFTER" >& 2
fi
