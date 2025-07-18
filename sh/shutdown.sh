#!/bin/bash

NAME=$(basename "$0")
LOCK="/tmp/$NAME.lock"
exec 8<>"$LOCK"
if ! flock -n 8; then
        echo "Already shutting down".
        exit 1
fi

REQ_PROGRAMS="mpc mocp whiptail systemctl dbus-send mocp xscreensaver-command"
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
                for PID in rsync curl wget ffmpeg apt-get; do
                        if pidof  ${PID} ; then
                                id=$(pidof ${PID} | tr " " ",")
                                echo "$0" "Väntar på ${PID} (${id})."
                                sleep "${SLEEP_TIME}"
                                AGAIN=true
                        fi
                done
                PROGS=(minsvtget spotdlsh youtube-dl)
                for PROG in ${PROGS[*]}; do
                        while pidof "${PROG}"; do
                                echo -- "$0" "Väntar på ${PROG}."
                                sleep "${SLEEP_TIME}"
                                AGAIN=true
                        done
                done
        done
}

function await_halt
{
        BACKUP="${HOME}/src/backup.sh"
        if [[ -e "$BACKUP" ]]; then
                bash "$BACKUP" -f
        fi
        BACKUP="${HOME}/src/nas.sh"
        if [[ -e "$BACKUP" ]]; then
                bash "$BACKUP" -f
        fi

        AGAIN=true
        while $AGAIN; do
                AGAIN=false
                for PID in apt aptitude youtube-dl svtget-dl cdparanoia; do
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

HALT="halt"
HIBERNATE="hibernate"
LOCK="lock"
REBOOT="reboot"
SHUTDOWN="shutdown"
SUSPEND="suspend"

if [ -z "$1" ]; then
        WHAT=$(whiptail --noitem --defaultno --radiolist "What do you want to do today?" 10 30 5 "$SUSPEND" "" "$HIBERNATE" "" "$REBOOT" "" "$HALT" "" "$LOCK" "" 3>&1 1>&2 2>&3)
else
        WHAT=$(echo "$1" | tr "[:upper:]" "[:lower:]")
fi

if [ -z "$WHAT" ]; then
        exit 1
fi

case $WHAT in
        "$HALT" | "$SHUTDOWN")
                # lock screen before waiting everything to finish, then halt
                xscreensaver-command -lock
                xscreensaver-command -lock
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
                # lock screen before waiting everything to finish, then hibernate
                xscreensaver-command -lock
                forall
                systemctl suspend
                ;;
        "$HIBERNATE")
                # lock screen before waiting everything to finish, then hibernate
                xscreensaver-command -lock
                forall
                systemctl hibernate
                ;;
        "$LOCK")
                xscreensaver-command -lock
                pause_player
                ;;
        *)
                echo "\"$WHAT\" is not possible. $HALT, $REBOOT, $SUSPEND, and $HIBERNATE are available options." 1>&2 && false
                ;;
esac

echo "Stänger ned: $(date)"

exit

