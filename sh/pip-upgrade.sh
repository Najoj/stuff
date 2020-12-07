#!/bin/bash

PIP="python3 -m pip"

$PIP install --upgrade pip
$PIP list --outdated --format=freeze    |\
        grep -v '^\-e'                  |\
        cut -d= -f1                     |\
        xargs -n1 $PIP install --upgrade

