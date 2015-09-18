#!/bin/sh

TXT="${HOME}/.lyrics/"$(mpc -f "%artist% - %title%" | head -n 1 )".txt"

[ -z ${EDITOR} ] && EDITOR=nano 

${EDITOR} "${TXT}"

exit $?
