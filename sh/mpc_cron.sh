#!/bin/bash
# This script runs once in a while and does some things with mpd

################################################################################
#  Given one argument, continue to move one song up to random position until
#  the argument is the last one.
move_up()
{
        # Move first to position after current
        if ! mpc -f "%file%" playlist | tail -1 | grep "$1"; then
                current_position=$(mpc -f "%position%" current)
                last_position=$(mpc -f "%position%" playlist | tail -1)
                mpc mv "$last_position" "$((current_position+1))"
        fi
        
        # Move the rest randomly
        flytta_upp="${HOME}/src/flytta_upp.sh"
        # If no argument, do nothing and return.
        if [[ -z "${1+x}" ]]; then
                return
        fi

        current_position=$(mpc -f "%position% %file%" playlist | grep " $1" | cut -d" " -f 1)
        last_position=$(mpc -f "%position%" playlist | tail -1)
        ((N=last_position-current_position))

        if [ -e "$flytta_upp" ]; then
                "${flytta_upp}" "$N"
        fi
}

# Update list, just in case
mpc -qw update

################################################################################
#  Remove files which does not exist
script="${HOME}/src/rmpl.sh"
if [ -e "$script" ]; then
        echo "Tar bort oönskade låtar..."
        "$script" cleanup
fi

################################################################################
#  Remove files which does not exist
script="${HOME}/src/ta_bort_filer_som_inte_finns_ur_mpd.sh"
if [ -e "$script" ]; then
        echo "Tar filer som inte finns... "
        "$script"
fi

################################################################################
#  Remove duplicated entries
script="${HOME}/src/ta_bort_dubletter_ur_mpd.sh"
if [ -e "$script" ]; then
        echo "Tar bort dubletter... "
        "$script"
fi

# For printout in end, save length before adding files
LENGTH_BEFORE=$(mpc playlist | wc -l)

################################################################################
# Remove played files from .osorterat catalogue, up until current song
current_position=$(mpc -f "%position%" current)
original_last_file=$(mpc -f "%file%" playlist | tail -n1)
echo -n "Lägger in spelade från .osorterat"
mpc -f "%file%" playlist | \
        head -n $((current_position-1)) | \
        grep --color=never ".osorterat/" | \
        tac | \
        while read -r file; do
                cd /media/musik/ || break

                DIR="$(dirname "$file")"
                BASE="$(basename "$file")"

                newfile="$DIR/../$BASE"
                mv "/media/musik/$file" "/media/musik/$newfile"

                mpc -qw update
                REAL="$(realpath "$DIR/../$BASE")"
                echo "${REAL_PATH#/media/musik/}" 

                mpc add "${REAL#/media/musik/}"
        done
move_up "$original_last_file"

################################################################################
#  Add new and shuffle
original_last_file=$(mpc -f "%file%" playlist | tail -n1)
bash /home/jojan/src/rensa_upp.sh -o
move_up "$original_last_file"


################################################################################
#   Add a few artists from .osorterat not in playlist
#playlist=$(mktemp)
#osorterat=$(mktemp)
#notinplaylist=$(mktemp)
#NUM=1

#mpc -f "%artist%" playlist      | sort -u                       > "$playlist"
#mpc -f "%artist%" ls .osorterat | tac | sed 1d | sort -u | shuf > "$osorterat"

#while read -r artist; do
        #if ! grep "^${artist}$" "${playlist}" > /dev/null; then
                #echo  "${artist}"
        #fi
#done < "${osorterat}" | shuf | head -n $NUM > "${notinplaylist}"

#original_last_file=$(mpc -f "%file%" playlist | tail -n1)
#echo "Lägger in nya från .osorterat"
#while read -r artist; do
        #NEW=$(mpc -f "%artist% %file%" ls .osorterat | \
                #grep --color=never ^"${artist}" | shuf | head -1 | \
                #sed "s~^${artist} ~~")

        #if [ -z "$NEW" ]; then
                #continue
        #fi

        #REAL_PATH=$(realpath "/media/musik/$NEW")
        #if [ -f "$REAL_PATH" ]; then
                #echo "${REAL_PATH#/media/musik/}" 
                #mpc -qw insert "${REAL_PATH#/media/musik/}" 
        #fi
#done < "${notinplaylist}"

#rm "$playlist" "$osorterat"
#move_up "$original_last_file"


################################################################################
#  Adjust songs titles
original_last_file=$(mpc -f "%file%" playlist | tail -n1)
/home/jojan/src/fixa_låtarna.sh
move_up "$original_last_file"

################################################################################
#  Done 
echo "Klar!"
LENGTH_AFTER=$(mpc playlist | wc -l)
LENGTH_DIFF=$((LENGTH_AFTER - LENGTH_BEFORE))
c=""
if [[ $LENGTH_DIFF -ge 0 ]]; then c='+'; fi
printf "Före:  %'d\nEfter: %'d (%c%'d)\n" "$LENGTH_BEFORE" "$LENGTH_AFTER" "$c" "$LENGTH_DIFF"

