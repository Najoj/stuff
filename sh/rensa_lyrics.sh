#!/usr/bin/env bash
# Clean up in ~/.lyrics which ncmpcpp creates.

DIR="${HOME}/.lyrics"
TMP="$(mktemp -d)"

du "${DIR}"/* | sort -g | grep -q ^0 | cut -f 2 | while read -r file; do
    rm -vf "$file"
done

for txt in "${DIR}/"*.txt; do
        # Remove special case, or
        # remove rediculously long files
        if grep -q ^Cancel "$txt"; then
                rm "$txt"
        elif grep -q 'How to Format Lyrics' "$txt"; then
                rm "$txt"
        elif grep -q '1 Cancel' "$txt"; then
                rm "$txt"
        elif wc -l "$txt" | grep -qE "^[1-9][0-9]{2,}(.+)\.txt"; then
                rm "$txt"
        elif head -1 "$txt" | grep -q 'Contributors'; then
                rm "$txt"
        fi
done

# Save files which has songs in mpd
mkdir "${TMP}" 2> /dev/null
mpc -f "%artist% - %title%.txt" playlist | while read -r file; do
    mv "${DIR}/${file}" "${TMP}" 2> /dev/null
done

rm -r "${DIR}"/*.txt
mv    "${TMP}"/*.txt "${DIR}"

rmdir "${TMP}"

