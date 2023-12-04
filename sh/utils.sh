#!/bin/bash
###############################################################################
#
# Various utilities which are commonly used in scripts.
#
# Load in other scripts to make them available.
#
###############################################################################

function print_warning() {
        # Print to stderr
        >&2 echo "$@"
}

function required_programs() {
        # Arguments are the names of programmes which are needed. Has to be
        # available in $PATH.
        # Return true on success, false otherwise.
        for req in "$@"; do
                if ! command -v "$req" > /dev/null; then
                        print_warning "Program \"$req\" is missing."
                        return 1
                fi
        done
        return 0
}

function required_files() {
        # Check for required files.
        # Return true on success, false otherwise.
        for req in "$@"; do
                if ! [[ -e "$req" ]]; then
                        print_warning "File \"$req\" is missing."
                        return 1
                fi
        done
        return 0
}
