#!/usr/bin/env bash
#
source "${HOME}/src/utils.sh"

if ! required_programs trurl yt-dlp; then
        exit 1
fi

((exit_status=0))

function manage
{
        local url
        local base
        local nwd
        local fullwd
        local retries
        local count

        url="$(trurl --qtrim "*" "$1")"
        base=$(echo "${url##*//}" | cut -d\. -f1)
        nwd=${url##*/}
        fullwd="${base}/${nwd}"
        fullwd="bandcamp/${fullwd}"

        mkdir -p "$fullwd" 
        cd "$fullwd" || return

        ((retries=5))
        ((count=0))
        until yt-dlp --ignore-config -x -ci --audio-format=vorbis "$url"; do
                if [[ "$retries" -le "$count" ]]; then
                        break
                fi
                ((count++))
                sleep 5
        done

        if [[ "$retries" -le "$count" ]]; then
                ((exit_status=1))
        fi

        cd "$wd" || cd ../..
}
cd /media/musik/.osorterat/oklart || (echo "Could not cd to oklart" && exit 1)

wd=$(pwd)
if [[ "$#" -gt 0 ]]; then
        for url in "${@}"; do
                manage "$url"
        done
else
        while read -r url; do
                manage "$url"
        done 
fi

exit "$exit_status"
