#!/bin/bash

INPUT="input.txt"

function down {
    PDIR=$(pwd)     # previous directory
    LIM=10
    
    TIT=$1          # title
    DIR=$2          # temporary directory
    URL=$3          # URL to video

    echo '>>>' ${TIT} '<<<'
    
    mkdir -p "$DIR"
    cd "${DIR}"
    
    for retries in {1..$LIM}; do
        if torify youtube-dl "$URL"; then
            break
        elif youtube-dl "$URL"; then
            break
        fi
        [ $LIM -eq $retries ] && return 1
    done

    touch "${DIR}/${INPUT}"  && \
    dir *.mp4 | while read file; do echo "file '$file'"; done > "${DIR}/${INPUT}" && \
    ffmpeg -f concat -i "${DIR}/${INPUT}" -c copy "${PDIR}/${TIT}".mp4

    cd "${PDIR}"
    
    [ -f "${PDIR}/${TIT}".mp4 ] && rm "${DIR}/"*.{mp4,txt} && rmdir "${DIR}"
    
    return 0
}

## Daily show
DSTIT="Daily Show $(date +%F)"
DSDIR="${HOME}/${DSTIT}"
DSURL='http://thedailyshow.cc.com/full-episodes'

## Nightly show
NSTIT="Nightly Show $(date +%F)"
NSDIR="${HOME}/${NSTIT}"
NSURL='http://www.cc.com/shows/the-nightly-show/full-episodes'

## Börjar nedladdningarna
if [ "$#" -eq 0 ]; then
#    down "$DSTIT" "$DSDIR" "$DSURL" || exit 1
    down "$NSTIT" "$NSDIR" "$NSURL" || exit 1
elif [ "$1" = "-d" ]; then
    down "$DSTIT" "$DSDIR" "$DSURL" || exit 1
elif [ "$1" = "-n" ]; then
    down "$NSTIT" "$NSDIR" "$NSURL" || exit 1
else
    echo "Vad pysslar du med?" >&2
fi
