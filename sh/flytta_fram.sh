#!/bin/bash
# Option to ensure success is changed saved from loop
shopt -s lastpipe

mpc -wq update

if [ "$1" ]; then
        what="%$1%"
else
        what="%artist%"
fi

if [ "$2" ]; then
        match="$2"
else
        match="$(mpc -f "$what" current)"
fi
match="$(echo "${match}" | tr '!?'"$'\(\)" '.')"

c=$(mpc -f "%position%" current)
((j=$((RANDOM % 7 + 5))))
((i=j))

success=false
mpc -f "%position% $what" playlist | \
        grep --color=never -E "^[1-9]([0-9]*) ${match}$" | \
        while read -r pos content; do
        if [ "$pos" -gt "$((c+j))" ]; then
                ((n=c+i))
                ((i+=j))
                printf "%'d -> %'d\n" "$pos" "$n"
                mpc -q mv "$pos" "$n"
                success=true
        fi
done

if $success; then
        exit 0
fi
exit 1

