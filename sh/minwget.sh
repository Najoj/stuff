#!/usr/bin/env bash


RET=0
while ! wget --tries=16 -U "$(cat ~/.useragent)" -c "$@"; do
    echo "Nytt försök om 10 sekunder."
    sleep 10
    RET=$((RET+1))
    if [ $RET -ge 10 ]; then
        break
    fi
done

exit $RET
