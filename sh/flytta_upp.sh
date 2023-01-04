#!/bin/bash
# Move the argument number of songs from the end of current MPD playlist to
# random position.

if [ "${1+x}" ] && [ "$1" -ge 0 ]; then
    # Remove non-digits
    N=${1/[^0-9]/}
else
    >&2 echo "Need argument."
fi

mpc -wq update

LEN=$(mpc playlist | wc -l)

BEFORE=$(mpc -f "%position%" current)
seq "$N" | while read -r; do
        CUR=$(($(mpc -f %position% current)+1))
        NEW=$(((RANDOM) % (LEN-CUR-N) + CUR))
        mpc mv "${LEN}" "${NEW}"
done
AFTER=$(mpc -f "%position%" current)

# Just a notice for the user if the current song position has been changed.
if ! [ "$BEFORE" -eq "$AFTER" ]; then
        >&2 echo "before $BEFORE != after $AFTER"
fi

