#!/usr/bin/env bash

command -v pygmentize less > /dev/null || exit 1
[ -f "$1" ] || exit 2

pygmentize "$@" | cat -n | less -R

exit $?
