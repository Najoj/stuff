#!/bin/bash
# Clean up in ~/.lyrics which ncmpcpp creates.

DIR="${HOME}/.lyrics"
TMP="${DIR}/tmp/"


for txt in "${DIR}/"*.txt; do
        # Remove special case, or
        # remove rediculously long files
        if grep ^Cancel "$txt" || \
                wc -l "$txt" | grep -E "^[1-9][0-9]{2,}(.+)\.txt"; then
                rm "$txt"
        fi
done

# Save files which has songs in mpd
mkdir "${TMP}"
mpc -f "%artist% - %title%.txt" playlist | while read -r file; do
    mv -v "${DIR}/${file}" "${TMP}";
done

rm "${DIR}"/*.txt
mv "${TMP}"*.txt "${DIR}"

rmdir "${TMP}"

