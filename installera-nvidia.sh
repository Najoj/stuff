#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "You ought to run this software as root." 1>&2
	cat $0
	exit 1
fi

VERSION=$1

apt-get install module-assistant nvidia-kernel-common	|| exit 2

m-a auto-install nvidia-kernel${VERSION}-source			|| exit 3

apt-get install nvidia-glx${VERSION}

cp -pv /etc/X11/xorg.conf /etc/X11/xorg.conf.bak$(date +%F)

cat << EOF > /etc/X11/xorg.conf || exit 4
Section "Module"
    Load        "glx"
EndSection

Section "Device"
    Identifier  "Video Card"
    Driver      "nvidia"
EndSection
EOF

whiptail --msgbox 'Now you have to restart screen' 10 30

exit 0
