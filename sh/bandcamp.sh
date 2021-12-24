#!/bin/bash

function manage
{
        ((retries=5))
        ((count=0))
        echo "$url"
        while ! youtube-dl -x -ci --audio-format=vorbis "$url"; do
                if [[ "$retries" -le "$count" ]]; then
                        break
                fi
                ((count++))
                sleep 5
        done

        if [[ "$retries" -le "$count" ]]; then
                return 1
        fi
        return 0
}

r=0
if [[ "$#" -gt 0 ]]; then
        for url in "${@}"; do
                ((r+=$(manage "$url")))
        done
else
        while read -r url; do
                ((r+=$(manage "$url")))
        done 
fi

exit "$r"
