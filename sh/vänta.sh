#!/usr/bin/env bash

if [ -z "${SLEEP}" ]; then
    SLEEP=${HOME}/bin/my_sleep
    if ! [ -e "${HOME}"/src/sleep ]; then
        SLEEP=$(command -v sleep)
    fi
fi

THEN=$(date +%s --date="$*")
${SLEEP} $((THEN-$(date +%s)))

