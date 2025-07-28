#!/bin/bash
source "${HOME}/src/utils.sh" || exit 1

# Ser om awk, cdparanoia och flac finns.
if ! required_programs awk cdparanoia flac; then
        exit 1
fi

ARTIST=""
ALBUM=""
DIR=""

while getopts :a:A:h:H:?: option; do
    #echo "${option}"
    case "${option}" in
        a)
            ARTIST=${OPTARG}
        ;;
        A)
            ALBUM=${OPTARG}
        ;;
        h|H)
            echo "$0 [-a artist] [-A album_title] dir"  >&2
        ;;
        \?|:)
            echo "Bajsargument. :-)" >&2
            exit 1
        ;;
    esac
done

shift $(( OPTIND - 1 ))

# Ser om något argument har givit och om det går att skapa mappen i så fall
if [ -n "$1" ]; then
    DIR=$1
elif [ -n "$ARTIST" ] && [ -n "$ALBUM" ] ; then
    DIR="$ARTIST/$ALBUM"
elif [ -n "$ARTIST" ]; then
    DIR="$ARTIST"
elif [ -n "$ALBUM" ]; then
    DIR="$ALBUM"
fi

if ! mkdir -p "$DIR"; then
    echo "Ange giltig katalog."  >&2
    exit 1
fi

# Kollar om inga spår finns.
if ! cdparanoia -Q &> /dev/null ; then
    echo "Inga spår fanns."  >&2
    exit 1
fi

# Hämtar antalet spår på cd:n
TRACKS=$(cdparanoia -Q 2>&1 | awk '{ print $1 }' | tail -n 3 | head -n 1 | tr -d ".")

echo -e "artist:\\t\"$ARTIST\"" >&2
echo -e "album:\\t\"$ALBUM\""    >&2
echo -e "spår:\\t\"$TRACKS\""  >&2
echo -e "mapp:\\t\"$DIR\""       >&2

# Går till mappen
cd "$DIR" || return 255

# Kopierar alla spår, ett spår i taget, och konverterar till flac.
for i in $(seq 1 "${TRACKS}"); do
    echo -e "\\n===================="
    echo    "  Spår ${i} av ${TRACKS}."
    echo    "===================="

    mkdir "tmp"
    cdparanoia -X "${i}" "tmp/${i}.wav"
    flac -f --best -o "track${i}.flac" "tmp/${i}.wav" \
        -T artist="$ARTIST" -T album="$ALBUM" -T track="$i"
done

