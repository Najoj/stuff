#!/bin/bash
VERSION="2020.02.16"

###
# lock
LOCK=/tmp/update-LOCK
function lock {
        if [ -e $LOCK ]; then
                echo "$0 already running"
                exit 0
        fi
        touch $LOCK
}
function unlock {
        rm -f $LOCK
}
###

function extra {
        lock;
        echo "Full uppgradering."
        srm -vf "$FILE" "$LOG"
        echo -e "EXTRA\t\t$(date)" | gzip - > $LOG

        sudo su -c \
                "   apt-get $Q update                                                       && \
                apt-get $Q autoremove                  --assume-yes                     && \
                apt-get $Q dist-upgrade                --assume-yes                     && \
                apt-get $Q autoclean                   --assume-yes                     && \
                apt-get $Q clean                                                        && \
                aptitude purge ~c                      --assume-yes                     && \
                \
                ${HOME}/src/update_hosts.sh
                        " 

                        avsluta
                }

        function regular {
                echo "Normal uppgradering."

                echo -e "\n\nNORMAL\t\t$(date)" | gzip - >> $LOG

                sudo su -c \
                        "   apt-get $Q update                                                       && \
                        apt-get $Q autoremove                  --assume-yes                     && \
                        apt-get $Q --only-upgrade upgrade      --assume-yes                     && \
                        apt-get $Q autoclean                   --assume-yes
                                        " 

                                        avsluta
                                }

                        function avsluta {
                                $SAVE && echo "$(date +%s)" | gzip - >> "$FILE"

                                sh ${HOME}/.oh-my-zsh/tools/upgrade.sh

                                unlock
                        }

                function update {
                        # If file exists
                        if [ -e "$FILE" ]; then
                                # First line is last "extra update" date, and last is "regular update" date
                                EXTRA=$(gunzip -c "$FILE" | head -n 1)
                                REGULAR=$(gunzip -c "$FILE" | tail -n 1)

                # Calculates what $NOW should be
                EXTRAL=$((EXTRA+BIG_LIMIT))
                REGULARL=$((REGULAR+SMALL_LIMIT))

                # If limit is passed to one thing or the other thing
                if [ $NOW -gt $EXTRAL ]; then
                        extra
                elif [ $NOW -gt $REGULARL ]; then
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
        unlock
}

function updatedates {
        # Updates the numbers
        NEXT_EXTRA=$((EXTRA+BIG_LIMIT))
        NEXT_REGULAR=$((REGULAR+SMALL_LIMIT))
        TOMORROW=$((NOW+60*60*24))


        if [ $NEXT_REGULAR -ge $NEXT_EXTRA ]; then
                NEXT_REGULAR=$NEXT_EXTRA
        fi

        echo -ne "dist-upgrade:   "
        if [ "$NEXT_EXTRA" -le "$NOW" ]; then
                echo "nu"
        else
                date --date=@"$NEXT_EXTRA" +"%a %_d %b %Y, klockan %T" \
                        | sed s/"$(date +"%a %_d %b %Y")"/"i dag"/ \
                        | sed s/"$(date --date @$TOMORROW +"%a %_d %b %Y")"/"i morgon"/ \
                        | sed s/"$(date +" %Y")"/""/

        fi

        echo -ne "     upgrade:   "
        if [ "$NEXT_REGULAR" -le "$NOW" ]; then
                echo "nu"
        else
                date --date=@"$NEXT_REGULAR" +"%a %_d %b %Y, klockan %T" \
                        | sed s/"$(date +"%a %_d %b %Y")"/"i dag"/ \
                        | sed s/"$(date --date @$TOMORROW +"%a %_d %b %Y")"/"i morgon"/ \
                        | sed s/"$(date +" %Y")"/""/
        fi
}

REQUIRED="srm fdupes apt-cache apt-get bc zcat gunzip date echo grep head less sed"
for software in $REQUIRED; do
        if ! command -v "$software" > /dev/null; then
                echo "$software not found." >&2
                exit 2
        fi
done

# Filer
FILE="${HOME}/.updatedate.gz"
LOG="${HOME}/.updatelog.gz"
EXTRA=$(gunzip -c "$FILE" | head -n 1)
REGULAR=$(gunzip -c "$FILE" | tail -n 1)
# Sekunder
BIG_LIMIT=$(( 365*60*60*24 / 12  ))
SMALL_LIMIT=$(( BIG_LIMIT / 4 ))
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
                -l)
                        if [ -e "$LOG" ]; then
                                less "$LOG"
                        else
                                echo "\"$LOG\" finns inte." 1>&2
                        fi
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
                        update
                        ;;
        esac
                        fi

                        unlock

                        exit 0

