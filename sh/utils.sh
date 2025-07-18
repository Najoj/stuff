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

function car () {

    # FORCE is used as flag by mv. If -f flag is not given, use interactive.
    FORCE=-i
    if [[ $1 == "-f" ]]; then
            FORCE=-f
            shift
    fi

	if [ $# -ne 2 ]
	then
        echo "Usage: car [-f] \"file1\" \"file2\""
		echo "if stat -c of file1 is greater than that of file2,"
		echo "replace file2 with file1, otherwise remove file1"
        echo "Optional first argument -f suppress promt, instead forces removals"
		return 1
	fi

    file_1="$(realpath "$1")" 
    filename="$(basename -- "$file_1")"
    file_2="$(realpath "$2")" 

    if [[ -d "$file_2" ]]; then
            file_2="${file_2}/${filename}"
            print_warning "$file_2 is a directory. Using $filename in directory."
    fi

	if [ "$file_1" = "$file_2" ]; then
		echo "The two files provided are the same."
		echo "Will not continue."
		return 1

	elif [ -f "$file_1" ] && [ ! -f "$file_2" ]; then
		mv $FORCE -v "$file_1" "$file_2"
	elif [ ! -f "$file_1" ] && [ -f "$file_2" ]; then
		mv $FORCE -v "$file_2" "$file_1"

	elif [ ! -f "$file_1" ] || [ ! -f "$file_2" ]; then
        echo "Usage: car \"$1\" \"$2\""
		echo "if stat -c of file1 is greater than that of file2,"
		echo "replace file2 with file1, otherwise remove file1"
		return 1
	else
		file1_size=$(stat -c %s "$file_1") 
		file2_size=$(stat -c %s "$file_2") 
		if [ "$file1_size" -gt "$file2_size" ]
		then
			mv $FORCE -v "$file_1" "$file_2"
		else
			rm -Iv "$file_1"
		fi
	fi
}

function run_python() {
        SCRIPT="$1"
        PYTHON="${HOME}/.mython/bin/python3"
        if ! [[ -e "$PYTHON" ]]; then
                print_warnig "Python not found: $PYTHON"
                PYTHON="python3"
        fi
        if ! [[ -e "$SCRIPT" ]]; then
                print_warnig "Script not found: $PYTHON"
                return 1
        fi
        "$PYTHON" "$SCRIPT"
}

pyexec() {
    # Check if the argument is provided
    if [ -z "$1" ]; then
            print_warning "Usage: $0 <file_to_check>"
            return 1
    elif ! [ -e "$1" ]; then
            print_warning "$1 does not exist"
            return 1
    fi
    MYTHON="${HOME}/.mython/bin/python3"
    # Check if MYTHON is a file
    if [[ -e "$MYTHON" ]]; then
            "$MYTHON" "${@:1}"
    elif which python3 > /dev/null; then
            python3 "${@:1}"
    else
            print_warning "No Python found"
            return 1
    fi
    return "$?"
}
