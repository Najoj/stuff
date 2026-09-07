#!/usr/bin/env bash
echo hej
source "${HOME}/src/utils.sh"

echo "$@" | grep -E "/(channel|user)/" && exit 1

required_programs trurl yt-dlp sleep || exit 1

AUDIO=false
if [[ "audio" == "$1" ]]; then
        AUDIO=true
        shift
fi

SLEEP="${HOME}/src/sleep"
[ -f "$SLEEP" ] || SLEEP="sleep"

WAIT="5s"
((LIM=5))
((C=0))

URL="$(trurl "$1")"
if $AUDIO; then
        until yt-dlp 2> /tmp/ytdl_stderr --no-warnings --all-subs   \
                -x "$URL" -o "${HOME}/%(title)s.%(ext)s"            \
                --audio-format vorbis --audio-quality 0             \
                --ignore-config --no-playlist  || [ "$C" -gt "$LIM" ] ; do
                ${SLEEP} "${WAIT}"
                ((C++))
                echo -e "\\n$C / $LIM"
        done
else
        until yt-dlp 2> /tmp/ytdl_stderr --no-warnings --all-subs   \
                -x "$URL" -o "${HOME}/%(title)s.%(ext)s"            \
                --no-live-chat                                      \
                --ignore-config --no-playlist  || [ "$C" -gt "$LIM" ] ; do
                ${SLEEP} "${WAIT}"
                ((C++))
                echo -e "\\n$C / $LIM"
        done
fi

