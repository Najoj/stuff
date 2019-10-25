#!/bin/bash

FILE=$1
DIR=$2

[ -f "$FILE" ] || exit 1

echo '>> '${FILE}' <<'

if   [[ "$FILE" =~ .*\.[Oo][Gg][Gg] ]]; then
    OUTPUT="${DIR}${FILE%.[Oo][Gg][Gg]}.ogg"
    mv -vn "$FILE" "$OUTPUT"

elif [[ "$FILE" =~ .*\.[Oo][Pp][Uu][Ss] ]]; then
    OUTPUT="${DIR}${FILE%.[Oo][Pp][Uu][Ss]}.ogg"
    which opusdec oggenc && ! [ -f "$OUTPUT" ] && \
    opusdec --force-wav "${FILE}" - | oggenc -m 128 -M 320 -o "${OUTPUT}" -

elif [[ "$FILE" =~ .*\.[Mm][Pp]3 ]]; then
    OUTPUT="${DIR}${FILE%.[Mm][Pp]3}.ogg"
    which mpg321 oggenc && ! [ -f "$OUTPUT" ] && \
    mpg321 "${FILE}" -w - | oggenc -m 128 -M 320 -o "${OUTPUT}" -

elif [[ "$FILE" =~ .*\.[Mm]4[Aa] ]]; then
    TEMP="$(mktemp).wav"
    OUTPUT="${DIR}${FILE%.[Mm]4[Aa]}.ogg"
    which avconv ffmpeg && ! [ -f "$OUTPUT" ] && \
    avconv -i "${FILE}" "${TEMP}" && \
    ffmpeg -i "${TEMP}" -acodec libvorbis "${OUTPUT}"

    rm -f "${TEMP}"

elif [[ "$FILE" =~ .*\.[Ww][Aa][Vv] ]]; then
    OUTPUT="${DIR}${FILE%.[Ww][Aa][Vv]}.ogg"
    which oggenc && ! [ -f "$OUTPUT" ] && \
    oggenc -o "${OUTPUT}" "${FILE}"

elif [[ "$FILE" =~ .*\.[Ff][Ll][Aa][Cc] ]]; then
    OUTPUT="${DIR}${FILE%.[Ff][Ll][Aa][Cc]}.ogg"
    which oggenc && ! [ -f "$OUTPUT" ] && \
    oggenc -m 128 -M 320 -o "${OUTPUT}" "${FILE}"

elif [[ "$FILE" =~ .*\.[Ww][Mm][Aa] ]]; then
    OUTPUT="${DIR}${FILE%.[Ww][Mm][Aa]}.ogg"
    which ffmpeg && ! [ -f "$OUTPUT" ] && \
    ffmpeg -i "${FILE}" -acodec libvorbis "${OUTPUT}"

elif [[ "$FILE" =~ .*\.[Aa][Ii][Ff][Ff] ]]; then
    OUTPUT="${DIR}${FILE%.[Aa][Ii][Ff][Ff]}.ogg"
    which ffmpeg && ! [ -f "$OUTPUT" ] && \
    ffmpeg -i "${FILE}" -acodec libvorbis "${OUTPUT}"

else
    false
fi

exit $?
