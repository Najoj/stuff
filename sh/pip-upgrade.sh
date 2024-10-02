#!/bin/bash
MYTHON="${HOME}/.mython/bin/python" 
if [[ -e "$MYTHON" ]]; then
        PIP="$MYTHON -m pip"
else
        PIP="python3 -m pip"
fi
$PIP install --upgrade pip
# shellcheck disable=SC2086
$PIP list --outdated    |\
        tail -n+3       |\
        cut -d' ' -f1   |\
        xargs $PIP install --upgrade

