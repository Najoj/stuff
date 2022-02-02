#!/bin/sh

if [ -z "$1" ]; then
	TODO=suspend
else
	TODO=$1
fi

! command -v mpc > /dev/null && echo "\"mpc\" saknas." && exit 1

for sh in   ${HOME}/src/spela_klart	\
            ${HOME}/src/shutdown.sh 	; do
    [ ! -f "$sh" ] && echo "\"$sh\" saknas." && exit 2
done

echo "Will \"${TODO}\"."

"${HOME}"/src/spela_klart.py || exit 1

mpc pause

"${HOME}"/src/shutdown.sh "$TODO"

exit $?
