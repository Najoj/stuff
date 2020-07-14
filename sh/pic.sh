#!/bin/bash

REQ="mpd mpc convert composite montage"

if ! pidof mpd &> /dev/null ; then
    echo "MPD is not running." 1>&2
    exit 1
else
    for p in ${REQ} ; do
        if ! command -v "${p}" &> /dev/null ; then
            echo "${p} is not installed." 1>&2
            exit 2
        fi
    done
fi

BASE="/media/musik/.omslag/"
ARTIST=$(mpc -f "%artist%" | head -1)
ALBUM=$( mpc -f "%album%"  | head -1)
SIZE="100x100"

CURRENT="$BASE""CURRENT.png"
CURRENT_MIRROR="$BASE""CURRENT_MIRROR.png"
# CURRENT_MIRROR_TRANS="$BASE""CURRENT_MIRROR_TRANS.png"
# COMBINED="$BASE""COMBINED.png"
# TRANS="$BASE""TRANS.png"

# These first flags are used when you have a picture that you want to be
# associated in a certain way. Used as
#   $0 [flag [picture]]

ALBU_FILE="$(echo           "$ALBUM" | tr '[:upper:]ÅÄÖ' '[:lower:]åäö' | tr -d '[:punct:][:cntrl:]' | tr -c '[:alnum:]åäö' '_').png"
ARTI_FILE="$(echo "$ARTIST"          | tr '[:upper:]ÅÄÖ' '[:lower:]åäö' | tr -d '[:punct:][:cntrl:]' | tr -c '[:alnum:]åäö' '_').png"
FULL_FILE="$(echo "${ARTI_FILE}__${ALBU_FILE}" | sed s/".png"//)"


################################################################################
# Artist and album
if [ "$1" == "-f" ] && ! [ -z "$ALBUM" ]; then
    if [ -z "$ALBUM" ]; then
        echo "Album finns ej." 1>&2
    else
        FILE="f/$FULL_FILE"
    fi

################################################################################
# Album (compilations for example)
elif [ "$1" == "-c" ]; then
    if [ -z "$ALBUM" ]; then
        echo "Album finns ej." 1>&2
    else
        FILE="c/$ALBU_FILE"
    fi

################################################################################
# Artist
elif [ "$1" == "-a" ]; then
    FILE="a/$ARTI_FILE"

elif [ "$1" == "-aw" ]; then
    FILE="aw/$ARTI_FILE"

elif [ "$1" == "-ab" ]; then
    FILE="ab/$ARTI_FILE"

################################################################################
# Errorous arguments
elif [ $# -gt 0 ]; then
    echo "Misslyckades med att förstå vad det var du ville göra." 1>&2
    exit 1

################################################################################
# Just copy the picture
else
    FILE=f/$FULL_FILE
    if [ ! -f "$BASE""$FILE" ] && [ ! "$FILE" == ".png" ]; then

        FILE=c/$ALBU_FILE
        if [ -z "$ALBUM" ] || [ ! -f "$BASE""$FILE" ]; then

            FILE=a/$ARTI_FILE
            if [ ! -f "$BASE""$FILE" ]; then
                FILE=".png"
            fi
        fi
    fi

    unlink "$BASE""CURRENT.png" && \
    ln -s "$BASE""$FILE" "$BASE""CURRENT.png"
fi

# More than one argument, then it is a file or an url.
if [ $# -gt 1 ]; then
    if [[ "$2" =~ http(s)?:// ]]; then
        wget -O - "$2" | convert -resize "$SIZE" - "$BASE$FILE"
    elif [ -f "$2" ]; then
        convert -resize "$SIZE" "$2" "$BASE$FILE"
        rm "$2"
    else
        echo "Misslyckades med att förstå vad \"$2\" är." 1>&2
        exit 1
    fi

    file "$BASE""$FILE"

    [ -f "$BASE""$FILE" ] && \
    unlink "$BASE""CURRENT.png" && \
    ln -s "$BASE""$FILE" "$BASE""CURRENT.png"

# Otherwise, it is hopefully none, and then we just echo the file name.
elif [ $# -gt 0 ]; then
    echo "$BASE""$FILE"
fi

convert -size "$SIZE" -flip "$CURRENT" "$CURRENT_MIRROR"
#composite -alpha on "$TRANS" "$CURRENT_MIRROR" "$CURRENT_MIRROR_TRANS" && \
#montage -tile 1x2 -geometry 100x100+0+0 -borderwidth 0x0+0+0 "$CURRENT" "$CURRENT_MIRROR_TRANS" "$COMBINED"

# För att se vilka bilder som inte brukats på länge.
[ -f "$BASE""$FILE" ] && touch "$BASE""$FILE"

exit 0
