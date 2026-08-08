#!/usr/bin/env bash

source "${HOME}/src/utils.sh" || exit 1

if [ -z "$1" ]; then
	TODO=suspend
else
	TODO=$1
fi

required_files "${HOME}/src/shutdown.sh" || exit 1

echo "Will \"${TODO}\"."

run_python "${HOME}"/src/spela_klart.py || exit 1

mpc -qw pause

"${HOME}"/src/shutdown.sh "$TODO"

exit $?
