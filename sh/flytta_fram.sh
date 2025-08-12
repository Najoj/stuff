#!/usr/bin/env bash
# Option to ensure `success` is changed saved from loop
shopt -s lastpipe

source "${HOME}/src/utils.sh"

if [[ "$1" == "--no-update" ]]; then
        shift
else
        mpc -wq update
fi

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
match="$(sanitize_regex "${match}")"

c=$(mpc -f "%position%" current)
((j=$((RANDOM % 7 + 5))))
((i=j))

success=false
mpc -f "%position% $what" playlist | \
        grep --color=never -E "^[1-9]([0-9]*) ${match}$" | \
        while read -r pos _content; do
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

