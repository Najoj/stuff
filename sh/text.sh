#!/bin/bash

DIR="/home/$USER/.lyrics"
FILE="$(mpc -qf "%artist% - %title%.txt" current)"

# echo "${DIR}/${FILE}"

if [ "$1" = "-d" ]; then
        rm -vf "${DIR}/${FILE}"
else
        vi "${DIR}/${FILE}"
fi
