#!/bin/bash

LADDANED="${HOME}/src/ladda_ned.sh"
FIL="${HOME}/.laddaned"
URL=$1

# echo $@ > ${HOME}/INNEHÅLL && beep -l 75 -r 2 || beep -f 50 -l 250

for URL in "$@"; do
   if [[ "${URL}" =~ http(s)?://(www\.)?(aftonbladet|comedycentral|di|dn|dplay|efn|expressen|kanal9play|tv4|svd|nickelodeon|ur|viafree|oppetarkiv|tv10play|tv3play|tv4play|tv6play|tv8play|urplay|svtplay)\.se ]]; then
       $LADDANED "$URL"
   else
       echo "$URL" >> "$FIL"
   fi
done

exit
