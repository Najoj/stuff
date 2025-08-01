#!/usr/bin/env bash
source "${HOME}/src/utils.sh"

FILE=$1
OUTPUT=$2

if [[ -z "${OUTPUT}" ]]; then
        OUTPUT="${FILE%.*}.ogg"
fi

if ! [ -e "$FILE" ]; then
        print_warning "Input file does not exist: $FILE"
        exit 1
elif [ -e "$OUTPUT" ]; then
        print_warning "Output file does already exist: $OUTPUT"
        exit 1
fi

[ -f "$FILE" ] || exit 1

echo "${FILE}  ->  ${OUTPUT}"

if   [[ "$FILE" =~ .*\.[Oo][Gg][Gg] ]]; then
    mv -vn "$FILE" "$OUTPUT"

elif [[ "$FILE" =~ .*\.[Oo][Pp][Uu][Ss] ]]; then
    command -v opusdec oggenc && ! [ -f "$OUTPUT" ] && \
    opusdec --force-wav "${FILE}" - | oggenc -m 128 -M 320 -o "${OUTPUT}" -

elif [[ "$FILE" =~ .*\.[Mm][Pp]3 ]]; then
    command -v mpg321 oggenc && ! [ -f "$OUTPUT" ] && \
    mpg321 "${FILE}" -w - | oggenc -m 128 -M 320 -o "${OUTPUT}" -

elif [[ "$FILE" =~ .*\.[Mm]4[Aa] ]]; then
    TEMP="$(mktemp).wav"
    command -v avconv ffmpeg && ! [ -f "$OUTPUT" ] && \
    avconv -i "${FILE}" "${TEMP}" && \
    ffmpeg -i "${TEMP}" -acodec libvorbis "${OUTPUT}"

    rm -f "${TEMP}"

else
    command -v oggenc && ! [ -f "$OUTPUT" ] && \
    ffmpeg -i "${FILE}" "${OUTPUT}" 
fi

exit $?
