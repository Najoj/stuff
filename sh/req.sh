#!/bin/bash

function require
{
        missing=0
        for program in "$@"; do
                if ! command -v "${program}" > /dev/null; then
                    echo "\"${program}\" is missing." 2> /dev/stderr
                    missing=$((missing + 1))
                fi
        done
        return $missing
}

