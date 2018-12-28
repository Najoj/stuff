#!/bin/sh

for req in df grep gawk; do
	if ! hash "$req" > /dev/null; then
		echo "\"$req\" saknas"
		exit 1
	fi
done

USED=$( df | grep ^/dev/ | gawk '{ print $3 }' | while read int; do echo -n "$int+"; done | sed s/+\$/\\n/ | bc )
TOTAL=$(df | grep ^/dev/ | gawk '{ print $2 }' | while read int; do echo -n "$int+"; done | sed s/+\$/\\n/ | bc )

echo 'USED:  '  ${USED}  1>&2
echo 'TOTAL: ' ${TOTAL} 1>&2

# Number of [TGM]iB in every kiB.
TB=1073741824
GB=1048576
MB=1024
#kB=1

# Terabyte
if [ ${USED} -gt ${TB} ]; then
    echo -n 'TB' 1>&2
    X=$(echo ${USED}/${TB} | bc -l)
    USED=$(printf "%.2fTiB" ${X})

# Gigabyte
elif [ ${USED} -gt ${GB} ]; then
    echo -n 'GB' 1>&2
    X=$(echo ${USED}/${GB} | bc -l)
    USED=$(printf "%.2fGiB" ${X})

# Megabyte
elif [ ${USED} -gt ${MB}  ]; then
    echo -n 'MB' 1>&2
    X=$(echo ${USED}/${MB} | bc -l)
    USED=$(printf "%.2fMiB" ${X})

# Kilobyte
else
    echo -n 'kB' 1>&2
    X=$(echo ${USED} | bc -l)
    USED=$(printf "%.2fkiB" ${X})
fi

echo -n ' af ' 1>&2

# Terabyte
if [ $TOTAL -gt ${TB}  ]; then
    echo 'TB' 1>&2
    X=$(echo $TOTAL/${TB} | bc -l)
    TOTAL=$(printf "%.2fTiB" ${X})

# Gigabyte
elif [ $TOTAL -gt ${GB}  ]; then
    echo 'GB' 1>&2
    X=$(echo $TOTAL/${GB} | bc -l)
    TOTAL=$(printf "%.2fGiB" ${X})

# Megabyte
elif [ $TOTAL -gt ${MB}  ]; then
    echo 'MB' 1>&2
    X=$(echo $TOTAL/${MB} | bc -l)
    TOTAL=$(printf "%.2fMiB" ${X})

# Kilobyte
else
    echo 'kB' 1>&2
    X=$(echo $TOTAL | bc -l)
    TOTAL=$(printf "%.2fkiB" ${X})
fi

echo "${USED} av $TOTAL"

exit 0
