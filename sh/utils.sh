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
    FORCE=-i
    if [[ $1 == "-f" ]]; then
            FORCE=-f
            shift
    fi

	if [ $# -ne 2 ]
	then
		echo "Usage: compare_and_replace file1 file2"
		echo "if stat -c of file1 is greater than file2,"
		echo "replace file2 with file1, otherwise remove file1"
        echo "Optional first argument -f suppress promt, instead forces removals"
		return 1
	fi

	file_1="$(realpath "$1")" 
	file_2="$(realpath "$2")" 
	if [ "$file_1" = "$file_2" ]
	then
		echo "The two files provided are the same."
		echo "Will not continue."
		return 1
	elif [ -f "$file_1" ] && [ ! -f "$file_2" ]
	then
		mv $FORCE -v "$file_1" "$file_2"
	elif [ ! -f "$file_1" ] && [ -f "$file_2" ]
	then
		mv $FORCE -v "$file_2" "$file_1"
	elif [ ! -f "$file_1" ] || [ ! -f "$file_2" ]
	then
		echo "Usage: compare_and_replace file1 file2"
		echo "if stat -c of file1 is greater than file2,"
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
