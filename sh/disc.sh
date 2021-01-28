#!/bin/bash

for req in df grep gawk; do
        if ! command -v "$req" > /dev/null; then
                echo "\"$req\" saknas"
                exit 1
        fi
done

USED=$( df | grep ^/dev/ | gawk '{ print $4 }' | while read -r int; do echo -n "$int+"; done | sed s/+\$/\\n/ | bc )
TOTAL=$(df | grep ^/dev/ | gawk '{ print $3 }' | while read -r int; do echo -n "$int+"; done | sed s/+\$/\\n/ | bc )

echo USED:   "${USED}"  1>&2
echo TOTAL:  "${TOTAL}" 1>&2

# Number of [TGM]iB in every kiB.
TB=1073741824
GB=1048576
MB=1024
#kB=1

# Terabyte
if [ "$USED" -gt "$TB" ]; then
        echo -n 'TB' 1>&2
        X=$((USED/TB))
        USED=$(printf "%.2fTiB" "${X}")

# Gigabyte
elif [ "$USED" -gt "$GB" ]; then
        echo -n 'GB' 1>&2
        X=$((USED/GB))
        USED=$(printf "%.2fGiB" "${X}")

# Megabyte
elif [ "$USED" -gt "$MB" ]; then
        echo -n 'MB' 1>&2
        X=$((USED/MB))
        USED=$(printf "%.2fMiB" "${X}")

# Kilobyte
else
        echo -n 'kB' 1>&2
        X=$((USED))
        USED=$(printf "%.2fkiB" "${X}")
fi

echo -n ' af ' 1>&2

# Terabyte
if [ "$TOTAL" -gt "$TB"  ]; then
        echo 'TB' 1>&2
        X=$((TOTAL/TB))
        TOTAL=$(printf "%.2fTiB" "${X}")

# Gigabyte
elif [ "$TOTAL" -gt "$GB"  ]; then
        echo 'GB' 1>&2
        X=$((TOTAL/GB))
        TOTAL=$(printf "%.2fGiB" "${X}")

# Megabyte
elif [ "$TOTAL" -gt "$MB" ]; then
        echo 'MB' 1>&2
        X=$((TOTAL/MB))
        TOTAL=$(printf "%.2fMiB" "${X}")

# Kilobyte
else
        echo 'kB' 1>&2
        X=$((TOTAL))
        TOTAL=$(printf "%.2fkiB" "${X}")
fi

echo "${USED} av ${TOTAL}"

