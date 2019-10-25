#!/bin/bash

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

    cmd="MP4Box "
    first=true
    dir *.mp4 | while read mp4; do
        if [ $first ]; then
            cmd="${cmd} -add ${mp4}"
            first=false
        else
            cmd="${cmd} -cat ${mp4}"
        fi
    done
    cmd="${cmd} ${TIT}.mp4"

    $cmd
    cd "${PDIR}"

    [ -f "${PDIR}/${TIT}".mp4 ] && rm "${DIR}/"*.{mp4,txt} && rmdir "${DIR}"

    return 0
}

## Daily show
DSTIT="Daily Show $(date +%F)"
DSDIR="${HOME}/${DSTIT}"
DSURL='http://www.cc.com/shows/the-daily-show-with-trevor-noah/full-episodes'


## Börjar nedladdningarna
if [ "$#" -eq 0 ]; then
    down "$DSTIT" "$DSDIR" "$DSURL" || exit 1
#elif [ "$1" = "-d" ]; then
    #down "$DSTIT" "$DSDIR" "$DSURL" || exit 1
elif [[ "$1" =~ http ]]; then
    down "Comedy Central surprise $(date +%s)" "${HOME}"/"CC $(date +"%F, %T")" "$1"
else
    echo "Vad pysslar du med?" >&2
fi
