#!/bin/bash

DIR="${HOME}/src/ln"
RET=0

for URL in "$@"; do
        PRET=$RET

        if [[ "${URL}" =~ http(s)?://(www\.|m\.)?youtube\.com/watch\? ]]                 ||
                [[ "${URL}" =~ http(s)?://(www\.|m\.)?youtube(-nocookie)?\.com/embed(ed)?/ ]] ||
                [[ "${URL}" =~ http(s)?://(www\.|m\.)?youtu\.be/ ]]                           ||
                [[ "${URL}" =~ http(s)?://invidio\.us/watch\? ]]                          ; then

        #torsocks ${DIR}/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )


elif [[ "${URL}" =~ http(s)?://((www|player)\.)?vimeo.com/ ]]; then

        torsocks "${DIR}"/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET))

        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http(s)?://(www\.)?metacafe.com/ ]]; then

        torsocks "${DIR}"/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET+1))
        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http(s)?://(www\.)?cjube.com/ ]]; then

        torsocks "${DIR}"/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http(s)?://(www\.)?dailymotion.com/ ]]; then

        torsocks "${DIR}"/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http://(www\.)?liveleak.com/view\?i= ]]; then

        torsocks "${DIR}"/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http(s)?://((w|www)\.)?[A-Za-z0-9]*\.bandcamp.com/ ]]; then

        torsocks "${DIR}"/youtube.sh -x --audio-format="vorbis" "${URL}"   || \
                "${DIR}"/youtube.sh -x --audio-format="vorbis" "${URL}"    || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http(s)?://((w|www)\.)?soundcloud.com/ ]]; then

        torsocks "${DIR}"/youtube.sh --audio-format=vorbis "${URL}"   || \
                "${DIR}"/youtube.sh --audio-format=vorbis "${URL}"    || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )

elif [[ "${URL}" =~ http(s)?://sverigesradio\.se/topsy/ljudfil/podrss/[0-9]+(\.|\-)[mM][pP]3 ]] || [[ "${URL}" =~ http(s)?://sverigesradio\.se/topsy/ljudfil/srse/[0-9]+(\.|\-)[mM][pP]3 ]]; then
        "${DIR}"/sr.sh "${URL}"     || \
                RET=$((RET+1))

        TXT=${URL}

elif [[ "${URL}" =~ http(s)?://(www\.)?(aftonbladet|comedycentral|di|dn|dplay|efn|expressen|kanal9play|tv4|svd|nickelodeon|ur|oppetarkiv|tv10play|tv3play|tv4play|tv6play|tv8play|urplay|svtplay)\.se ]]; then

        export DISPLAY=":0"
        urxvt -title 'svtget' -cd "$(pwd)" -e "${HOME}"/src/minsvtget.sh "${URL}" &
        disown


        TXT="Öppnades i egent fönster: $?"
        sleep 1s

elif [[ "${URL}" =~ (\.)[mM][pP]3 ]]; then
        "${DIR}"/sr.sh "${URL}"     || \
                RET=$((RET+1))

        TXT=${URL}
elif [[ "${URL}" =~ (\.)([Pp][Nn][Gg]|[Jj][Pp]([Ee])?[Gg]) ]]; then
        LIMIT=10
        TIME=30
        i=0

        FILE="$(date +%F-%T)-${RANDOM}.png"
        while ! wget -c "${URL}" -O - | convert - "${FILE}" && $LIMIT -le $i; do
                echo -en "försöker igen... om $TIME ($i/$LIMIT)"
                i=$((i+1))
        done ||\
                RET=$((RET+1))

        TXT="bild nedladdad"

elif [[ "${URL}" =~ (\.)([Mm][Pp]4|(Oo][Gg)([Gg]|[Aa]|[Vv]))(\?)?.* ]]; then

        FILE=$(echo "$URL" | sed -e s/"^http\(\(.\)*\/\)\+"// | sed s/"\?.*$"//)
        "${HOME}"/src/minwget.sh "$URL" -O "$FILE"

        TXT="film nedladdad"
else
        torsocks "${DIR}"/youtube.sh "${URL}"   || \
                "${DIR}"/youtube.sh "${URL}"          || \
                RET=$((RET+1))

        TXT=$( youtube-dl --get-filename "${URL}" )

        RET=$((RET+1))
fi

TXT="$(echo "$TXT" | cut -c -80)"
if [ $RET -eq $PRET ]; then
        echo -e '\e[1;32m'"Klar med \"$TXT\""'\033[0m' | head -1 >&2
else
        echo -e '\e[1;31m'"Kan inte behandla \"$URL\""'\033[0m' >&2
fi
done

exit $RET
