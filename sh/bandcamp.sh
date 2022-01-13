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

wd=$(pwd)
r=0
if [[ "$#" -gt 0 ]]; then
        for url in "${@}"; do
                nwd=${url##*/}
                mkdir "$nwd" 
                cd "$nwd" || continue
                ((r+=$(manage "$url")))
                cd "$wd" || cd ..
        done
else
        while read -r url; do
                nwd=${url##*/}
                mkdir "$nwd" 
                cd "$nwd" || continue
                ((r+=$(manage "$url")))
                cd "$wd" || cd ..
        done 
fi

exit "$r"
