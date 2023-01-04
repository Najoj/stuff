#!/bin/bash

PIP="python3 -m pip"
$PIP install --upgrade pip
# shellcheck disable=SC2086
$PIP list --outdated --format=freeze    |\
        grep -v '^\-e'                  |\
        cut -d= -f1                     |\
        xargs -n1 $PIP install --upgrade

