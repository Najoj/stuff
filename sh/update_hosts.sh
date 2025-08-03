#!/usr/bin/env bash
# Uppdaterar /etc/hosts
# Skript uppdaterat 2023-12-04

if [ $UID -ne 0 ]; then
    echo -e "Kräver root för att skriva över nuvarande hosts-fil."
fi

D=$(date  +"%F_%R")
HOSTS=/etc/hosts
if [ $UID -ne 0 ]; then
    NYHOSTS="${HOME}/hosts.${D}"
else
    NYHOSTS="${HOSTS}.${D}"
fi

# Skapar temporär fil.
TMP=$(mktemp)

# Sparar det gamla
AVG="SPARA ALLT OVANFÖR"

echo "Bygger ny hosts-fil till $NYHOSTS."
echo -e "##### SKAPAD $D\\n" | tr "_" " "   > "$NYHOSTS"

head -n "$(grep -n -m 1 "${AVG}" $HOSTS | awk '{ print $1-1 }' )" "$HOSTS"  | tail -n +3 >> "$NYHOSTS"
echo "###### ${AVG} ######" >> "$NYHOSTS"

################################################################################
#
#  Someonewhocares.org  ##  Måste vara före alla andra sidor!
#

echo -n "Laddar ned ny hosts-fil från someonewhocares.org till $TMP... "
wget -t2 -T20 -q http://someonewhocares.org/hosts/zero/hosts -O "$TMP"  || \
    (echo "Kunde inte hämta hosts-fil. Avslutar" 1>&2 && rm -v "$TMP" ; exit 1)

echo "och lägger den i $NYHOSTS."
echo -e "##### SIDOR FRÅN http://someonewhocares.org/\\n" >> "$NYHOSTS"
sed s/\#0/0/g "$TMP" | grep ^"0.0.0.0" | grep -v "localhost" | sort -g | uniq >> "$NYHOSTS"

################################################################################
#
#  MVPS.org
#

echo -n "Laddar ned ny hosts-fil från mvps.org till $TMP... "
wget -t2 -T20 -q http://winhelp2002.mvps.org/hosts.txt -O - | grep -v ^"#" > "$TMP"  || \
    (echo "Kunde inte hämta hosts-fil. Avslutar" 1>&2 && rm -v "$TMP" ; exit 1)

echo "och lägger den i $NYHOSTS."
echo -e "\\n\\n##### SIDOR FRÅN http://winhelp2002.mvps.org/\\n" >> "$NYHOSTS"
sed s/'127.0.0.1'/'0'/g "$TMP" | grep -v "localhost" | sort -g | uniq | grep -v ^$ >> "$NYHOSTS"

################################################################################
#
#  sbc.io
#

echo -n "Laddar ned ny hosts-fil från sbc.io till $TMP... "
wget -t2 -T20 -q http://sbc.io/hosts/alternates/fakenews-gambling-porn-social/hosts -O - | grep -v ^"#" > "$TMP"  || \
    (echo "Kunde inte hämta hosts-fil. Avslutar" 1>&2 && rm -v "$TMP" ; exit 1)

echo "och lägger den i $NYHOSTS."
echo -e "\\n\\n##### SIDOR FRÅN http://sbc.io/\\n" >> "$NYHOSTS"
grep -v ^$ "$TMP" | sed s/'127.0.0.1'/'0'/g | grep -Ev "(localhost|broadcasthost)" | sort -g | uniq >> "$NYHOSTS"

################################################################################

sed s/[^a-z0-9]$//g < "$NYHOSTS" > "$TMP"
cp "$TMP" "$NYHOSTS"

################################################################################

rm -v "$TMP"

newl=$(wc -l "$NYHOSTS" | cut -d' ' -f1)
oldl=$(wc -l "$HOSTS"   | cut -d' ' -f1)
printf "%'d nya rader\n" "$((newl-oldl))"
echo
if [ $UID -ne 0 ]; then
    echo "Kopierar inte $NYHOSTS till $HOSTS."
else
    echo "Kopierar $NYHOSTS till $HOSTS."
    cp -v "$NYHOSTS" $HOSTS
fi

# Förra årets samling av hosts-filer
if ls -l $HOSTS.$(($(date +%Y ) - 1 ))* 2> /dev/null; then
    echo "Du kanske vill ta bort dessa filer. Men det får du göra själv."
fi

echo "Klar."

