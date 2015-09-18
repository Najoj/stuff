#!/bin/bash
# Uppdaterar /etc/hosts
# Skript uppdaterat 2015-06-01

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


################################################################################
#
#  Someonewhocares.org  ##  Måste vara före alla andra sidor!
#
SWC="someonewhocares"

echo "Bygger ny hosts-fil till $NYHOSTS."
echo -e "##### SKAPAD $D\n" | tr "_" " "   > $NYHOSTS

if ! grep ${SWC} $HOSTS &> /dev/null ; then
    echo "##### SIDOR FRÅN http://${SWC}.org/hosts/" >> $HOSTS
fi

head -n $(grep -n -m 1 "${SWC}" $HOSTS | gawk '{ print $1-1 }' ) "$HOSTS"  | tail -n +3 >> $NYHOSTS

echo -n "Laddar ned ny hosts-fil från someonewhocares.org till $TMP... "
wget -q http://someonewhocares.org/hosts/hosts -O $TMP  || \
    (echo "Kunde inte hämta hosts-fil. Avslutar" 1>&2 && rm -v $TMP ; exit -1)
    
echo "och lägger den i $NYHOSTS."
echo -e "##### SIDOR FRÅN http://someonewhocares.org/hosts/\n" >> $NYHOSTS
cat $TMP | sed s/\#127/127/g | grep ^"127.0.0.1" | grep -v "localhost" >> $NYHOSTS

################################################################################
#
#  MVPS.org
#

echo -n "Laddar ned ny hosts-fil från mvps.org till $TMP... "
wget -q http://winhelp2002.mvps.org/hosts.txt -O - | grep -v ^"#" > $TMP  || \
    (echo "Kunde inte hämta hosts-fil. Avslutar" 1>&2 && rm -v $TMP ; exit -1)

echo "och lägger den i $NYHOSTS."
echo -e "\n\n##### SIDOR FRÅN http://winhelp2002.mvps.org/hosts.txt\n" >> $NYHOSTS
cat $TMP | grep -v ^$ | sed s/'0.0.0.0'/'127.0.0.1'/g | grep -v "localhost" >> $NYHOSTS

################################################################################

rm -v $TMP

if [ $UID -ne 0 ]; then
    echo "Kopierar inte $NYHOSTS till $HOSTS."
else
    echo "Kopierar $NYHOSTS till $HOSTS."
    cp -v $NYHOSTS $HOSTS
fi

# Förra årets samling av hosts-filer
if ls -l $HOSTS.$(($(date +%Y ) - 1 ))* 2> /dev/null; then
    echo "Du kanske vill ta bort dessa filer. Men det får du göra själv."
fi

echo "Klar."
exit 0
