#/bin/sh

if [ $# -lt 1 ]; then
    DAT="1988-05-04 00:00"
else
    DAT=$@
fi
IDAG=$(date               +%s)
FDAG=$(date --date="$DAT" +%s)

DAGAR=$(( (${IDAG}-${FDAG}) / (60*60*24) ))

if factor "$DAGAR" | wc -w | grep ^2$ > /dev/null ; then
    echo -n '\033[1;32m\033[44m' ${DAGAR} '\033[0m'
elif echo "$DAGAR" | grep 00$ > /dev/null ; then
    echo -n '\033[36m\033[40m' ${DAGAR} '\033[0m'
else
    echo -n "${DAGAR}"
fi

echo -n " dagar"
