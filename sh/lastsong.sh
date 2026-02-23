#!/usr/bin/env bash

source "${HOME}/src/utils.sh" || exit 1

if [ -z "$1" ]; then
	TODO=suspend
else
	TODO=$1
fi

if ! required_files "${HOME}/src/spela_klart"	\
                    "${HOME}/src/shutdown.sh"; then
                    exit 1
elif ! required_files "${HOME}/.mython/bin/python"; then
        PYTHON=${HOME}/.mython/bin/python
else
        PYTHON=python3
fi


echo "Will \"${TODO}\"."

"$PYTHON" "${HOME}"/src/spela_klart.py || exit 1

mpc -qw pause

"${HOME}"/src/shutdown.sh "$TODO"

exit $?
