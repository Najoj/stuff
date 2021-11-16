#!/bin/bash

NAME=$(basename "$0")
LOCK="/tmp/$NAME.lock"
exec 8<>"$LOCK"
if ! flock -n 8; then
        echo "Already shutting down".
        exit 1
fi

REQ_PROGRAMS="mpc whiptail systemctl dbus-send mocp"
REQ_SCRIPTS="ch_vol.sh"
SLEEP_TIME="2m"

for prog in $REQ_PROGRAMS; do
        (! hash "${prog}") && echo "\"${prog}\" saknas." && exit 1
done

for script in $REQ_SCRIPTS; do
        if ! [ -f "${HOME}/src/${script}" ]; then
                echo "\"${script}\" saknas." 1>&2
                exit 1
        fi
done

function forall
{
        pause_player
        all_downloaded
        remove_stuff
}

function all_downloaded
{
        AGAIN=true
        while $AGAIN; do
                AGAIN=false
                for PID in curl wget ffmpeg apt-get; do
                        if pidof  ${PID} ; then
                                id=$(pidof ${PID} | tr " " ",")
                                echo "$0" "Väntar på ${PID} (${id})."
                                sleep "${SLEEP_TIME}"
                                AGAIN=true
                        fi
                done
                PROG=minsvtget
                if ! pgrep ${PROG} | wc -l | grep ^0$; then
                        echo -- "$0" "Väntar på ${PROG}."
                        sleep "${SLEEP_TIME}"
                        AGAIN=true
                fi
        done
}

function await_halt
{
        AGAIN=true
        while $AGAIN; do
                AGAIN=false
                for PID in youtube-dl svtget-dl; do
                        if pgrep "${PID}" ; then
                                id=$(pgrep "${PID}" | sed "s/\\n/\\ /")
                                echo -- "$0" "Väntar på ${PID} (${id})."
                                sleep "${SLEEP_TIME}"
                                AGAIN=true
                        fi
                done
        done
}

function remove_stuff
{
        true
}

function pause_player
{
        mocp --pause
        mpc pause
        mpc --wait update && mpc --wait save "säkerhetskopia-$(date +%s)"
        "${HOME}"/src/ch_vol.sh normalise >  /dev/null &
}

HIBERNATE="hibernate"
SUSPEND="suspend"
REBOOT="reboot"
HALT="halt"

if [ -z "$1" ]; then
        WHAT=$(whiptail --noitem --defaultno --radiolist "What do you want to do today?" 10 30 4 "$SUSPEND" "" "$HIBERNATE" "" "$REBOOT" "" "$HALT" ""  3>&1 1>&2 2>&3)
else
        WHAT=$(echo "$1" | tr "[:upper:]" "[:lower:]")
fi

if [ -z "$WHAT" ]; then
        exit 1
fi

case $WHAT in
        "$HALT")
                await_halt
                forall
                dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.PowerOff" boolean:true
                ;;
        "$REBOOT")
                await_halt
                forall
                dbus-send --system --print-reply --dest=org.freedesktop.login1 /org/freedesktop/login1 "org.freedesktop.login1.Manager.Reboot" boolean:true
                #dbus-send --system --print-reply --dest=org.freedesktop.ConsoleKit /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart
                ;;
        "$SUSPEND")   # Suspend
                forall
                systemctl suspend
                ;;
        "$HIBERNATE")
                forall
                systemctl hibernate
                ;;
        *)
                echo "\"$WHAT\" is not possible. $HALT, $REBOOT, $SUSPEND, and $HIBERNATE are available options." 1>&2 && false
                ;;
esac

exit $?
