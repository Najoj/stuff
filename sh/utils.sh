#!/usr/bin/env bash
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

# Compare sizes of the given inputs. Keep the greater file at $2.
# $2 could be a directory, then check for the same basename of $1 in $2.
function car () {
    # FORCE is used as flag by mv. If -f flag is not given, use interactive (-i).
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

# Sanitize before regex usage
function sanitize_regex() {
    local input="$1"
    local sanitized
    # Escape special regex characters
    # shellcheck disable=SC2016
    sanitized=$(printf '%s\n' "$input" | sed 's/[.*+?[^$(){}|\\]/\\&/g')
    echo "$sanitized"
}

# Waits for current song in MPD to finish
function spela_klart() {
        local num
        local _iterations

        num=$1
        if [[ -z "${num}" ]]; then
                ((num=1))
        fi
        for ((_iterations=0; _iterations<num; _iterations++)); do
                mpc current --wait > /dev/null
        done
}

# If the argument is an integer
function is_int() {
        [[ "$1" =~ ^-?[0-9]+$ ]]
}

# executes command and logs
function run_log() {
        local logfile
        local lineno
        local command

        if [[ -f "$1" ]] || touch "$1"; then
                logfile="$1"
        else
                print_warning "$1 does not exist"
                logfile="/dev/stderr"
        fi

        if is_int "$2"; then
                lineno=$2
        else
                lineno=0
        fi

        if [[ $# -gt 2 ]]; then
                shift 2
                command=("${@}")

                echo "${lineno}: ${command[*]}" >> "$logfile"
                if "${command[@]}"; then
                        true
                else
                        print_warning "FAILED EXECTUTON: $?"
                        false
                fi >> "$logfile"
        else
                echo "Error running: run_log \"$*\"" >> "$logfile"
                false
        fi
}

function progress_bar() {
        if is_int "$1" && is_int "$2" && [[ $1 -le $2 ]] && [[ $1 -ge 0 ]]; then
                local current=$1
                local len=$2
                local perc_done=$((100 * current / len))
                local suffix=" $current/$len ($perc_done%)"
                local length=$((80 - 2))
                local num_bars=$((perc_done * length / 100))

                local i
                local s='['

                for ((i = 0; i < num_bars; i++)); do
                        s+='#'
                done
                for ((i = num_bars; i < length; i++)); do
                        s+=' '
                done

                s+=']'

                >&2 printf "\r%s %'d / %'d (%d%%)" "$s" "$current" "$len" "$perc_done"
        else
                return 1
        fi
}

# Unique lines in file
function unique_lines() {
        local file
        local temp
        local total
        local c
        file="$1"
        temp="$(mktemp)"

        if [[ -e "$file" ]]; then
                total="$(wc -l "$file" | tr -cd "[0-9]")"
                ((c=0))
                progress_bar "$c" "$total"

                while read -r line; do
                        ((c++))
                        progress_bar "$c" "$total"
                        sane="$(sanitize_regex "$line")"
                        if ! grep -qE "$sane" "$temp"; then
                                echo "$line" >> "$temp"
                        fi
                done < "$file"
                mv -f "$temp" "$file"
        else
                return 1
        fi
}

