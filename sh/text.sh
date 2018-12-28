#!/bin/bash

TXT="${HOME}/.lyrics/"$(mpc -f "%artist% - %title%" current | tr \/ ' ' )".txt"
URLA="http://www.azlyrics.com/lyrics/$(mpc -f "%artist%/%title%" current       \
    | sed s/'The Clash'/'Clash'/                                              \
    | tr -d \ \&\?\!\,\.\'\-\(\)                                              \
    | tr "[:upper:]" "[:lower:]" ).html"

URLM="http://www.metrolyrics.com/$(mpc -f "%title%-lyrics-%artist%" current     \
    | tr "[:upper:] " "[:lower:]-"                                             \
    | tr -d "\"\.\?\!\'"                                                       \
    | sed s/'-the-offspring'/'-offspring'/                                     \
    | sed s/'-ramones'/'-the-ramones'/                                   ).html" 

[ -z "$1" ] || URL="$1"

if [ -z "$URL" ]; then
    if [ 0 == $(($RANDOM % 2)) ]; then
        URL="${URLA}"
    else
        URL="${URLM}"
    fi
fi

echo $URL
echo $TXT

if ! [ -f "$TXT" ]; then
    links -dump "$URL" | sed s/'   '// | tee "$TXT" | grep -i \ lyrics | head -n 5
    RET=$?
    grep -- "404 - Page Not Found" "$TXT" && rm "$TXT"
fi


exit $RET

