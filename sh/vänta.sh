#!/bin/bash

if [ -z "${SLEEP}" ]; then
    if [ -e "${HOME}"/src/sleep ]; then
        SLEEP=${HOME}/src/sleep
    else
        SLEEP=$(command -v sleep)
    fi
fi

THEN=$(date +%s --date="$*")
${SLEEP} $((THEN-$(date +%s)))

echo $((THEN-$(date +%s)))

