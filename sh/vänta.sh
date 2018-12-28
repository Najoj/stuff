#!/bin/bash

if [ -z ${SLEEP} ]; then
    if [ -e ${HOME}/src/sleep ]; then
        SLEEP=${HOME}/src/sleep
    else
        SLEEP=$(which sleep)
    fi
fi

${SLEEP} $(($(date +%s --date="$@")-$(date +%s)))

exit $?
