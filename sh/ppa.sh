#!/bin/bash
## This is a script to add Ubuntu PPA repositories in Debian.
## Use as  $0 ppa:ubuntu-mozilla-daily/ppa
##  or as  $0 https://launchpad.net/~ubuntu-mozilla-daily/+archive/ppa
## But it does not check if the URLs are correctyly formated. So that will make
## a crash. Run as root to automise it a little more.

# See if there is no argument at all.
if [ $# -eq 0 ]; then
        grep ^\#\# "$0"
                exit -1
fi

# If there was a ppa url or an http url.
if [ "$(echo "$1" | cut -c -3)" == "ppa" ]; then
        TITLE=$(echo "$1" | sed "s/ppa\\://g" | tr "/" " " | gawk '{ print $1 }')
        PPA="https://launchpad.net/~$TITLE/+archive/$(echo "$A" | gawk '{ print $2 }')"
else
        PPA="$1"
fi

# Get the data will be put into /etc/apt/sources.list. I do not know if lucid is
# the best, but it is LTS.
DATA=$(links -dump "$PPA"  | grep -A 1 "deb http" | sed "s/^[ ]*//" | sed s/YOUR_UBUNTU_VERSION_HERE/lucid/)

# Key to be added
KEY=$(links -dump "$PPA"  | grep -A 1 "Signing key:" | tail -n 1 | tr -d "[:blank:]" | cut -c 7-14)

# Ubuntu's keyserver
SERVER="apt-key adv --keyserver pgp.mit.edu --recv-keys $KEY"

# If you are root, I will add to sources.list and add GPG keys.
if [ $UID -eq 0 ]; then
        if $SERVER; then
                echo -en "\\n## $(links -dump "$PPA" \
                        | head -n 4 \
                        | tail -n 1) \
                        PPA added on $(date +"%F %T").\\n$DATA" >> /etc/apt/sources.list \
                else 
                        echo "FAILED" 1>&2 ; exit -1
                fi
        else
                echo "Run:  $SERVER"
                echo "and add the following to /etc/apt/sources.list:"
                echo "$DATA"
        fi

        exit 0
