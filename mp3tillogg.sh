#!/bin/bash

FILE=$1

[ -f "$FILE" ] || exit 1

echo '>> '${FILE}' <<'
if   [[ "$FILE" =~ .*\.[Mm][Pp]3 ]]; then
    OUTPUT="${FILE%.[Mm][Pp]3}.ogg"
    which mpg321 oggenc && ! [ -f "$OUTPUT" ] && \
    mpg321 "${FILE}" -w - | oggenc -m 128 -M 320 -o "${OUTPUT}" -
    
elif [[ "$FILE" =~ .*\.[Mm]4[Aa] ]]; then
    OUTPUT="${FILE%.[Mm]4[Aa]}.ogg"
    which faad oggenc && ! [ -f "$OUTPUT" ] && \
    faad "${FILE}" -o -   | oggenc -o "${OUTPUT}" -
    
elif [[ "$FILE" =~ .*\.[Ww][Aa][Vv] ]]; then
    OUTPUT="${FILE%.[Ww][Aa][Vv]}.ogg"
    which oggenc && ! [ -f "$OUTPUT" ] && \
    oggenc -o "${OUTPUT}" "${FILE}"

elif [[ "$FILE" =~ .*\.[Ff][Ll][Aa][Cc] ]]; then
    OUTPUT="${FILE%.[Ff][Ll][Aa][Cc]}.ogg"
    which oggenc && ! [ -f "$OUTPUT" ] && \
    oggenc -m 128 -M 320 -o "${OUTPUT}" "${FILE}"

elif [[ "$FILE" =~ .*\.[Ww][Mm][Aa] ]]; then
    OUTPUT="${FILE%.[Ww][Mm][Aa]}.ogg"
    which ffmpeg && ! [ -f "$OUTPUT" ] && \
    ffmpeg -i "${FILE}" -acodec libvorbis "${OUTPUT}"

elif [[ "$FILE" =~ .*\.[Aa][Ii][Ff][Ff] ]]; then
    OUTPUT="${FILE%.[Aa][Ii][Ff][Ff]}.ogg"
    which ffmpeg && ! [ -f "$OUTPUT" ] && \
    ffmpeg -i "${FILE}" -acodec libvorbis "${OUTPUT}"
    
else
    false
fi

exit $?
