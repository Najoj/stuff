#!/bin/bash

if [ -z "${SLEEP}" ]; then
    if [ -e "${HOME}"/src/sleep ]; then
        SLEEP=${HOME}/src/sleep
    else
        SLEEP=$(command -v sleep)
    fi
fi

${SLEEP} $(($(date +%s --date="$*")-$(date +%s)))

exit $?
