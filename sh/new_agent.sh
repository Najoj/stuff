#!/bin/bash

REQ=(grep head sed shuf tr wget)
for req in "${REQ[@]}"; do
        if ! command -v "$req" &> /dev/null; then
                echo "Progam \"$req\" is missing" &> /dev/stderr
                exit 1
        fi
done

TMP=$(mktemp)
USERAGENT="${HOME}/.useragent"

wget https://jnrbsn.github.io/user-agents/user-agents.json -O- | \
        shuf | \
        grep --color=never Firefox |\
        head -1 |\
        tr -d ",\"" |\
        sed "s/^[ ]*//" > "$TMP"

if [ -s "$TMP" ]; then
        mv "$TMP" "$USERAGENT"
fi

