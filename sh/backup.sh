#!/bin/bash

###############################################################################
#  Just a dull, simple backup script. Has to be ran as root.
################################################################################

if [ ! $UID == 0 ] ; then
    echo "run as root" 1>&2
    exit -1
fi

################################################################################
# Variables

HDD="/dev/sdd2"
HDDNAME="backup"
TEMPDIR="/tmp/backup"
INFO="backup_info"
IPROG="installed_programs"
HOME="${HOME}"
YEAR=$(date +%Y)
ECHO="echo -en"


################################################################################
# Create directory and mount drive

$ECHO "mkdir and mount... "
mkdir "$TEMPDIR"                         || $ECHO "failed mkdir... "      1>&2
mount "${HDD}" "${TEMPDIR}"              || $ECHO "failed to mount... "   1>&2
$ECHO "done\n"

################################################################################
# Check wether partition has been used for bockup prior.
if ! [ -f "$TEMPDIR/$INFO" ]; then
    $ECHO "Sorry. Not a valid backup directory."
    $ECHO "Create $TEMPDIR/$INFO to make it valid"
    $ECHO "I will _NOT_ unmount"
    exit 1
fi

################################################################################
# If there is a new year we remove all old files, and replace.

OLDYEAR=$(tail -n 1 "$TEMPDIR/$INFO" 2> /dev/null || $ECHO "0")
$ECHO "check year... "
if [ $YEAR -ne $OLDYEAR ]; then
    $ECHO "new year, remove files... "
    rm -r "$TEMPDIR" &> /dev/null || $ECHO "failed to remove files... "
else
    $ECHO "same year... "
    if [ "$1" == "XXXCLEANXXX" ] && \
        whiptail  --yesno "Vill du ta bort allt från $HDD?" 10 40 ; then
        $ECHO "ok, will remove anyway... "
        rm -rf "$TEMPDIR" &> /dev/null || $ECHO "failed to remove files... "
    fi
fi
$ECHO "done\n"

################################################################################
# Files to be synced

for file in                                                                    \
${HOME}/lösenord.kdbx                                                          \
/etc                                                                           \
/var/www                                                                       \
/var/lib/dpkg                                                                  \
/var/lib/apt/extended_states                                                   \
${HOME}/.{bash,co,zsh,vim}*                                                    \
${HOME}/bilder                                                                 \
${HOME}/.calcurse                                                              \
${HOME}/dokument                                                               \
${HOME}/gitspara                                                               \
${HOME}/.mpd*                                                                  \
${HOME}/.{ncmpcpp,moc}                                                         \
${HOME}/{lösenord.kdbx,skola.tgz}                                              \
${HOME}/src                                                                    \
${HOME}/.{Xdefaults,aliases,thunderbird,newsboat}                              \
${HOME}/.xmobar*                                                               \
${HOME}/.xmonad                                                                \
/media/musik/*/                                                                \
/media/musik/.omslag/                                                          \
/media/musik/.spara/                                                           \
/media/video/Big\ Bang\ Theory\,\ The/0\*                                      \
/media/video/Friday\ Night\Dinner/                                             \
/media/video/Black\ Books/                                                     \
/media/video/Family\ Guy/\*.mkv                                                \
/media/video/Historieätarna/                                                   \
/media/video/Simpsons\,\ The/\*mkv                                             \
/media/video/Svenska\ dialektmysterier/                                        \
/media/video/Värsta\ språket/                                                  \
; do
    N=$($ECHO ${file} | sed "s/[\/\ \,]//g")
    $ECHO "sync: \"${file}\"  ->   \"$TEMPDIR/$N\"... "
    rsync -aq "${file}" "$TEMPDIR/$N"   2> /dev/null
    $ECHO "done\n"
done

################################################################################
# APT stuff that might be good to have. Copying these because it will not take
# a lot of time. Almost the same as if it would syncing.

$ECHO "cp apt stuff... "
mkdir -p "$TEMPDIR/apt/"                    || $ECHO "could not mkdir apt... "
cp "/etc/apt/sources.list" "$TEMPDIR/apt/"  || $ECHO "could cp sources.list... "
cp "/etc/apt/"*.gpg "$TEMPDIR/apt/"         || $ECHO "could cp *.gpg... "
$ECHO "done\n"

################################################################################
# Save the installed programs programs.
# dpkg --set-selections < ~/packages && apt-get dselect-upgrade.

$ECHO "save installed programs... "
dpkg --get-selections "*" > "$TEMPDIR/$IPROG"
$ECHO "done\n"

################################################################################
# Just some info

$ECHO "backup info... "
$ECHO -e "Latest backup: $(date +"%F %T")\n"  > "$TEMPDIR/$INFO"
$ECHO "Files:" >> "$TEMPDIR/$INFO"
ls -R "$TEMPDIR" | sed "s|$TEMPDIR|/TEMPDIR|g" >> "$TEMPDIR/$INFO"
$ECHO -e "\n$YEAR" >> "$TEMPDIR/$INFO"
$ECHO "done\n"

################################################################################
# Unmount and remove the created directory

$ECHO "umount and rmdir... "
umount "$TEMPDIR"               || $ECHO "failed umount... "     1>&2
rmdir  "$TEMPDIR"               || $ECHO "failed rmdir... "      1>&2

$ECHO "done\n"

################################################################################

exit 0
