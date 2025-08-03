#!/usr/bin/env bash
source "${HOME}/src/utils.sh"

echo "$@" | grep -E "/(channel|user)/" && exit 1

COOKIES="${HOME}/.ytdlc"
SETTINGS="${HOME}/.yts"

required_programs youtube-dl sleep || exit 1
required_files "$COOKIES" "$SETTINGS" || exit 1

USERNAME="$(head -1 "$SETTINGS")"
PASSWORD="$(tail -1 "$SETTINGS")"

SLEEP="${HOME}/src/sleep"
[ -f "$SLEEP" ] || SLEEP="sleep"

WAIT="5s"
((LIM=5))
((C=0))

until youtube-dl \
        --username="$USERNAME" \
        --password="$PASSWORD" \
        --cookies="$COOKIES" \
        --ignore-errors \
        --no-playlist \
        --continue \
        --format="bestvideo[height<=?1028]+bestaudio/best" \
        "${@: 1:((${#}-1))}" -- "${@: -1}" || [ "$C" -gt "$LIM" ] ; do
	${SLEEP} "${WAIT}"
    ((C++))
	echo -e "\\n$C / $LIM"
done

if [ "$C" -ge $LIM ]; then
    C=0
    until mullvad-exclude youtube-dl \
            --username="$USERNAME" \
            --password="$PASSWORD" \
            --cookies="$COOKIES" \
            --ignore-errors \
            --no-playlist \
            --continue \
            --format="bestvideo[height<=?1028]+bestaudio/best" \
            "${@: 1:((${#}-1))}" -- "${@: -1}" || [ "$C" -ge $LIM ] ; do
            ${SLEEP} "${WAIT}"
            ((C++))
            echo -e "\\n$C / $LIM"
    done
fi

[ "$C" -ge $LIM ] && exit 1

