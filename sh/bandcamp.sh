#!/bin/bash
#
source "${HOME}/src/utils.sh"

if ! required_programs trurl youtube-dl; then
        exit 1
fi

function manage
{
        url="$(trurl --qtrim "*" "$url")"
        base=$(echo "${url##*//}" | cut -d\. -f1)
        if [ -z "${1+x}" ]; then
                return  1
        fi

        nwd=${url##*/}
        fullwd="${base}/${nwd}"
        fullwd="bandcamp/${fullwd}"

        mkdir -p "$fullwd" 
        cd "$fullwd" || return 1

        #echo "$fullwd" 
        #sleep 10

        ((retries=5))
        ((count=0))
        #echo "$url"
        until youtube-dl -x -ci --audio-format=vorbis "$url"; do
                if [[ "$retries" -le "$count" ]]; then
                        break
                fi
                ((count++))
                sleep 5
        done

        if [[ "$retries" -le "$count" ]]; then
                return 1
        fi


        cd "$wd" || cd ../..
        return 0
}
cd /media/musik/.osorterat/oklart || (echo "Could not cd to oklart" && exit 1)

wd=$(pwd)
((r=0))
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
