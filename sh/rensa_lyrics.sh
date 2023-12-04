#!/bin/bash
# Clean up in ~/.lyrics which ncmpcpp creates.

DIR="${HOME}/.lyrics"
TMP="$(mktemp -d)"

du "${DIR}"/* | sort -g | grep ^0 | cut -f 2 | while read -r file; do
    rm -vf "$file"
done

for txt in "${DIR}/"*.txt; do
        # Remove special case, or
        # remove rediculously long files
        if grep ^Cancel "$txt"; then
                rm -v "$txt"
        elif grep 'How to Fromat Lyrics' "$txt"; then
                rm -v "$txt"
        elif grep '1 Cancel' "$txt"; then
                rm -v "$txt"
        elif wc -l "$txt" | grep -E "^[1-9][0-9]{2,}(.+)\.txt"; then
                rm -v "$txt"
        fi
done

# Save files which has songs in mpd
mkdir "${TMP}" 2> /dev/null
mpc -f "%artist% - %title%.txt" playlist | while read -r file; do
    mv -v "${DIR}/${file}" "${TMP}" 2> /dev/null
done

rm -rv "${DIR}"/*.txt
mv -v "${TMP}"/*.txt "${DIR}"

rmdir "${TMP}"

