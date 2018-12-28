#!/bin/sh

if [ -z $1 ]; then 
	TODO=Hibernate
else
	TODO=$1
fi

! which mpc > /dev/null && echo "\"mpc\" saknas." && exit 1

for sh in   ${HOME}/src/spela_klart.py	\
            ${HOME}/src/shutdown.sh 	; do
    [ ! -f "$sh" ] && echo "\"$sh\" saknas." && exit 2
done

echo "Will \"${TODO}\"."

${HOME}/src/spela_klart.py

mpc pause

${HOME}/src/shutdown.sh $TODO

exit $?
