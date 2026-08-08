#!/usr/bin/env bash

source "${HOME}/src/utils.sh" || exit 1
LOG="${HOME}/.fördela.log"

date >> "$LOG"
echo "$@" >> "$LOG"

if [[ "$1" == "--no-update" ]]; then
        shift
else
        mpc -q update
fi

if [ $# -eq 0 ]; then
        >&2 echo "Arguments must exist"
        exit 1
fi

artist="(.+)"
title="(.+)"
album="(.*)"
time="(.+)"
freq="(.*)"
file="(.+)"

# Arguments
no_args="true"
while getopts "a:t:A:T:F:f:" option; do
        case "${option}"
                in
                a) artist=${OPTARG//[$?!]/\.};;
                A) album=${OPTARG//[$?!]/\.};;
                f) freq=${OPTARG//[$?!]/\.};;
                t) title=${OPTARG//[$?!]/\.};;
                T) time=${OPTARG//[$?!]/\.};;
                F) file=${OPTARG//[$?!]/\.};;
                *) >&2 echo "faulty flag: ${option}"; exit 1;;
        esac
        no_args="false"
done

if $no_args; then
        >&2 echo "need argument"
        exit 1
fi

# Formats
mpc_format="%artist% - %title% (%album%) %time% (%file%)"
grep_format="$artist - $title \($album\) $time \($file\)"


playlist_length=$(mpc -f "%position%" playlist | wc -l)
echo "playlist_length = ${playlist_length}" >> "$LOG"
current_position=$(mpc -f "%position%" current)

occurance=$(mpc -f "$mpc_format" playlist | \
        tail -n "$((playlist_length-current_position))" | \
        grep -Ec '^'"${grep_format}"'$')


if [ "$occurance" -eq 0 ]; then
        >&2 echo "No occurances of \"$grep_format\" found."
        exit 1
fi

c=${current_position}
diff=$((playlist_length-c))

# frequency
if [ -z ${freq+x} ]; then 
        f=${freq}
        if [ "$f" -le 1 ]; then
                >&2 echo "argument -f ($f) has to be greater than 1" >&2 
                exit 2
        fi
else
        f=$(echo "$diff / $occurance" | bc -l )
fi
f="${f%.*}"

last_song="$(mpc -f "%file%" playlist | tail -1)"
echo "last_song = ${last_song}" >> "$LOG"
# Move all matching to the end
mpc -f "%position% ${mpc_format}" playlist  | \
        tail -n ${diff} | \
        grep -E '^'"[0-9]+ ${grep_format}"'$'    | \
        cut -d" " -f1   | \
        tac             | \
        while read -r pos; do
                run_log "$LOG" "$LINENO" mpc -wq mv "$pos" "$playlist_length" 
                echo "$pos -> $playlist_length"
        done
# Move up last songs
i=1
n="$(echo $((c + i * f)) | cut -d'.' -f1)"
echo "last_song = ${last_song}" >> "$LOG"
mpc -f "%file%" playlist | tail -1 >> "$LOG"
while [ "$(mpc -f "%file%" playlist | tail -1)" != "${last_song}" ]; do
        if [ "$n" -gt "$playlist_length" ]; then
                run_log "$LOG" "$LINENO" echo "Break: $n -gt $playlist_length"
                break
        else
                pos=${playlist_length}
                run_log "$LOG" "$LINENO" mpc -wq mv "$pos" "$n"
                echo "$pos -> $n"
                # Next position
                ((i++))
                n=$(echo $((c + i * f)) | cut -d'.' -f1)
        fi
done

