#!/bin/bash
# Clean up in ~/.lyrics which ncmpcpp creates.

DIR="${HOME}/.lyrics/"
TMP="${DIR}tmp/"

mkdir "${TMP}"
mpc -f "%artist% - %title%.txt" playlist | while read -r file; do
    mv -v "${DIR}${file}" "${TMP}";
done

rm "${DIR}"*.txt
mv "${TMP}"*.txt "${DIR}"

rmdir "${TMP}"

# Special case, though it could missmatch.
for txt in "${DIR}"*.txt; do
        grep ^Cancel "$txt" && rm "$txt"
done

