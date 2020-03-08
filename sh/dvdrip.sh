#!/bin/bash

# Ser om mencoder finns.
if ! command -v mencoder &> /dev/null ; then
        echo "mencoder måste installeras"
        exit 1
fi

# Ser om något argument har givit och om det går att skapa mappen i så fall
DIR="$1"
if [ $# -eq 0 ] || ! mkdir -p "$DIR"; then
        echo "Ange giltig katalog."
        exit 1
fi

# Går till mappen
cd "$DIR" || exit 1

# Kopierar alla spår, ett spår i taget, och konverterar till mp4.
T=0
while mencoder dvd://${T} -oac pcm -ovc copy -o "spår${T}.mp4"; do
        echo -e "\\nSpår ${T} klar ===="
        T=$((T+1))
done
