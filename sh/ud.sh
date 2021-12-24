#!/bin/bash -e
VERSION="2021.12.12"

function lock {
        NAME=$(basename "$0")
        LOCK="/tmp/${NAME}.lock"
        exec 8> "$LOCK"

        if ! flock -n -x 8; then
                echo "Uppdatering redan igång."
                exit 1
        fi
}

###

function extra {
        lock
        echo "Full uppgradering."

        sudo su -c \
            "   apt-get $Q update                                           && \
                apt-get $Q autoclean                   --assume-yes         && \
                apt-get $Q clean                                            && \
                apt-get $Q autoremove                  --assume-yes         && \
                apt-get $Q dist-upgrade                --assume-yes         && \
                \
                ${HOME}/src/update_hosts.sh
        " 
        $SAVE && rm -v "${FILE}"
        avsluta
}

function regular {
        lock
        echo "Normal uppgradering."


        sudo su -c \
            "   apt-get $Q update                                           && \
                apt-get $Q autoremove                  --assume-yes         && \
                apt-get $Q --only-upgrade upgrade      --assume-yes         && \
                apt-get $Q autoclean                   --assume-yes
            " 
        python3 -m pip install --no-warn-script-location --upgrade pip
        cabal update

        avsluta
}

function avsluta {
        $SAVE && date +%s | gzip - >> "$FILE"
        sh "${HOME}/.oh-my-zsh/tools/upgrade.sh"
}

function check_update {
        # If file exists
        if [ -e "$FILE" ]; then
                # First line is last "extra update" date, and last is "regular update" date
                EXTRA=$(gunzip -c "$FILE" | head -n 1)
                REGULAR=$(gunzip -c "$FILE" | tail -n 1)

                # Calculates what $NOW should be
                EXTRAL=$((EXTRA+BIG_LIMIT))
                REGULARL=$((REGULAR+SMALL_LIMIT))

                # If limit is passed to one thing or the other thing
                if [ "$NOW" -gt "$EXTRAL" ]; then
                        extra
                elif [ "$NOW" -gt "$REGULARL" ]; then
                        regular
                fi
        else
                extra
        fi
}

function check {
        lock
        sudo apt-get update
        apt list --upgradable -a
}

function updatedates {
        # Updates the numbers
        ((NEXT_EXTRA=EXTRA+BIG_LIMIT))
        ((NEXT_REGULAR=REGULAR+SMALL_LIMIT))
        ((TOMORROW=NOW+60*60*24))


        if [ "$NEXT_REGULAR" -ge "$NEXT_EXTRA" ]; then
                NEXT_REGULAR=$NEXT_EXTRA
        fi

        echo -ne "dist-upgrade:   "
        if [ "$NEXT_EXTRA" -le "$NOW" ]; then
                echo "nu"
        else
                date --date=@"$NEXT_EXTRA" +"%a %_d %b %Y, klockan %T" \
                        | sed "s/$(date +"%a %_d %b %Y")/i dag/" \
                        | sed "s/$(date --date @"$TOMORROW" +"%a %_d %b %Y")/i morgon/" \
                        | sed "s/$(date +" %Y")//"

        fi

        echo -ne "     upgrade:   "
        if [ "$NEXT_REGULAR" -le "$NOW" ]; then
                echo "nu"
        else
                date --date=@"$NEXT_REGULAR" +"%a %_d %b %Y, klockan %T" \
                        | sed "s/$(date +"%a %_d %b %Y")/i dag/" \
                        | sed "s/$(date --date @"$TOMORROW" +"%a %_d %b %Y")/i morgon/" \
                        | sed "s/$(date +" %Y")//"
        fi
}

REQUIRED=(fdupes apt-cache apt-get bc zcat gunzip date echo grep head less sed
          flock)
for software in ${REQUIRED[*]}; do
        if ! command -v "$software" > /dev/null; then
                echo "$software not found." >&2
                exit 2
        fi
done

# Filer
FILE="${HOME}/.updatedate.gz"
EXTRA=$(gunzip -c "$FILE" | head -n 1)
REGULAR=$(gunzip -c "$FILE" | tail -n 1)
# Sekunder
BIG_LIMIT=$(( 365*60*60*24 / 12  ))
SMALL_LIMIT=$(( BIG_LIMIT / 3 ))
NOW=$(date +%s)

# Lyckovariabel
SAVE=true

if [ $# -gt 1 ]; then
        echo "Only one argument is allowed." 1>&2
else
        case "${1}" in
                -c)
                        check
                        ;;
                -h)
                        echo "less $0"
                        ;;
                -s)
                        regular
                        ;;
                -ts)
                        EXTRA=$(zcat "$FILE" | head -n 1)
                        REGULAR=$(zcat "$FILE" | tail -n 1)

                        EXTRAL=$((EXTRA+BIG_LIMIT-NOW))
                        REGULARL=$((REGULAR+SMALL_LIMIT-NOW))

                        if [ $EXTRAL -gt $REGULARL ]; then
                                echo $REGULARL
                        else
                                echo $EXTRAL
                        fi

                        ;;
                -tx)
                        EXTRA=$(zcat "$FILE" | head -n 1)
                        EXTRAL=$((EXTRA+BIG_LIMIT-NOW))
                        echo $EXTRAL
                        ;;
                -v)
                        echo "$VERSION"
                        ;;
                -w)
                        if [ -e "$FILE" ]; then
                                updatedates
                        else
                                echo "\"${FILE}\" does not exist." 1>&2
                        fi
                        ;;
                -x)
                        extra
                        ;;
                *)
                        check_update
                        ;;
        esac
fi

exit 0

