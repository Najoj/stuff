#!/bin/bash

UTILS="${HOME}/src/utils.sh"
[[ -e  "$UTILS" ]] || exit 1
# shellcheck source=src/utils.sh
source "$UTILS"


DIR="/media/musik"
SHUFFLE="true"
OSORT="false"
 
TMP="$(mktemp)"
FORD="${HOME}/.fördelade"
FRAM="${HOME}/.framflyttade"
ID3TAG="${HOME}/src/id3extract"

required_files "$ID3TAG" "$FORD" "$FRAM" "$DIR" || exit 1
required_programs mpc flock || exit 1

# Exit status
((OK=0))
# Limit to get an artist directory
((DIRLIMIT=6))
# Playlist limit
if [ -z ${MAX_PLAYLIST_LENGTH+x} ]; then
        ((LIMIT=MAX_PLAYLIST_LENGTH+I))
else
        ((LIMIT=20000+I))
fi

function clear_list {
        file="${1}"
        artist="$(${ID3TAG} artist "${DIR}/${file}")"
        sed -i "/$artist/d" "$FORD"
        sed -i "/$artist/d" "$FRAM"
}

#################################
#  Uppdaterar.                  #
#################################

echo -e "\n================================================================================"
echo -n "Uppdaterar databas..."
mpc -w update > /dev/null || exit 1
echo " klar!"

LENGTH=$(mpc playlist | wc -l)

#################################
#  Rensar upp i min musikmapp.  #
#################################

for arg in "$@"; do
        case "$arg" in
                "-o")
                        if [ "$LENGTH" -ge "$LIMIT" ]; then
                                >&2 echo "Spellistan är $LENGTH, vilket är över gränsen $LIMIT. Rens!"
                                OSORT="false"
                                ((OK=1))
                        else
                                OSORT="true"
                        fi
                ;;
                "-s")
                        SHUFFLE="mpc shuffle"
                ;;
                *)
                        echo "wat: \"$arg\"" 1>&2
                        exit 1
                ;;
        esac
done

#################################

echo -e "\n================================================================================"
echo -n "Börjar med att säkerhetskopiera spellistan: "
spellista="säkerhetskopia-$(date +%s)"
echo "\"${spellista}\"" 
mpc -wq update || exit 1
mpc -w save "$spellista"  || exit 1

cd "$DIR" || exit 1

#################################

if $OSORT; then
        echo -e "\n================================================================================"
        echo -n "Undersöker .osorterat-mappen... "
        _LEN=$(find "${DIR}/.osorterat/" -maxdepth 1 -type f -and \( -name "*.flac" -or -name "*.ogg" \) | wc -l)
        if ls "${DIR}/.osorterat/"*.ogg > /dev/null || ls "${DIR}/.osorterat/"*.flac > dev/null; then
                cd "${DIR}/.osorterat/" || exit 1

                LIMITA=$(( (LIMIT-LENGTH) / 2))
                LIMITB=$((LIMIT-LENGTH-LIMITA))

                # äldst
                echo "Lägger till $LIMITA gamla filer." 
                find . -maxdepth 1 -type f -printf "%T+ %p\n" \
                        | sort | cut -d' ' -f 2- | head -n "$LIMITA" \
                        | while read -r track; do
                        if [[ -e "$track" ]]; then
                            car "${track}" "${DIR}/${track}"   && \
                            mpc -qw update              && \
                            mpc -w add "${track#./}"
                        fi
                done | cat -n

                # populära artister
                echo "Lägger till $LIMITB filer på måfå." 
                cd "${DIR}/.osorterat/" || exit 1
                find . -maxdepth 1 -type f -and \( -name "*.flac" -or -name "*.ogg" \) \
                        | shuf | tail -n $LIMITB | while read -r track; do
                        if [[ -e "$track" ]]; then
                                car "${track}" "${DIR}/${track}"   && \
                                mpc -qw update              && \
                                mpc -w add "${track#./}"
                        fi
                done | cat -n
        fi
fi

################################

cd "$DIR" || exit 1
echo -e "\n================================================================================"
echo "Flyttar på band som börjar med \"The\"." 
find . -maxdepth 1 -type f -name 'The *' -a '(' -name '*\.flac' -o -name '*\.ogg'  ')' | \
while read -r band; do
        newband="${band#./The }" 
        newband="${newband// - /, The - }"
        mv -vn "${band}" "${newband}"    && \
        mpc -wq update                  && \
        mpc -w add "${newband#./}"
done

# Directories
find . -maxdepth 1 -type d -name 'The *' | \
while read -r dir; do
        newdir="${dir#./The }, The"
        mv -vn "${dir}" "${newdir}"  && \
        mpc -wq update              && \
        mpc -w add "${newdir#./}"
done

#################################

cd "$DIR" || exit 1
echo -e "\n================================================================================"
echo "Undersöker om några band redan har mappar."
find . -maxdepth 1 -type f -name \*" - "\* | sed -E 's/ - .+//' | sort -u | \
while read -r band; do
        if ls -d "${band}/" &> /dev/null ; then
                mv -uvn "${band} - "* "${band}/"
                cd "${band}" || break
                # Remove inital ./
                band=${band#./}
                find . -name "${band} - "\* | sed -E 's/.+ - //' | \
                while read -r title; do
                        mv -vn "${band} - ${title}" "${title}"   && \
                        mpc -wq update                          && \
                        mpc -w add "${band#./}/${title}"
                done
                mpc -wq update
        fi
        cd "$DIR" || exit 2
done

#################################

cd "$DIR" || exit 1
echo -e "\n================================================================================"
echo "Undersöker om några band ska ha mappar."
find . -maxdepth 1 -name \*" - "\* -type f | \
    grep -Ev '.(omslag|spellistor|osorterat|torrenter)' | \
    sed 's/ - /\n/' | grep -Ev "\\.(ogg|flac)"$ | sort -g | uniq  | \
while read -r band; do
        N=$(find . -maxdepth 1 -name "${band#./} - *\\.*" -type f | wc -l)
        if [ "$N" -ge "$DIRLIMIT" ]; then
                first=true
                mkdir "${band}"
                mv -vn "${band} - "* "${band}/" || break
                cd "${band}" || exit 1
                find . -maxdepth 1 -type f | cut -c 3- | while read -r bandtitle; do
                        # shellcheck disable=SC2001
                        title="$(echo "$bandtitle" | sed s/"${band#./} - "//)"
                        if [ -n "$title" ]; then
                                #echo "$bandtitle -> $title"
                                (car "${bandtitle}" "${title}"     && \
                                 mpc -wq update) || continue
                                if $first; then
                                        mpc -w insert "${band#./}/${title}"
                                        clear_list "${band#./}/${title}"
                                        first=false
                                else
                                        mpc -w add "${band#./}/${title}"
                                fi
                        else
                                print_warning "$bandtitle gave empty title"
                        fi

                done
        fi
        cd "$DIR" || exit 2
done

#################################

cd "$DIR" || exit 2
echo -e "\n================================================================================"
echo "Undersöker om några låtar ska nedgraderas."
find . -maxdepth 1 -type d -and -not -name '.*' -and -not -path "./lost+found" | \
while read -r band; do
        cd "${band}" || continue
        N=$(find . -maxdepth 1 -type f -name "*.*" 2> /dev/null | wc -l)
        if ! ls ./*/ &> /dev/null && [ "$N" -lt "$DIRLIMIT" ]; then
                first=true
                grep -Fv "${band#./}" "${FORD}" > "${TMP}" && mv "$TMP" "$FORD"
                grep -Fv "${band#./}" "${FRAM}" > "${TMP}" && mv "$TMP" "$FRAM"
                find . -maxdepth 1 -type f -name "*.*" 2> /dev/null | \
                cut -c 3- | \
                while read -r title; do
                        car "${title}" ../"${band} - ${title#./}"
                        mpc -wq update
                        if $first; then
                                mpc -w insert "${band#./} - ${title}"
                                clear_list "${band#./} - ${title}"
                                first=false
                        else
                                mpc -w add "${band#./} - ${title}"
                        fi
                done
        fi
        cd "$DIR" || exit 2
        rmdir "${band}" 2> /dev/null
done

#################################

eval "$SHUFFLE" > /dev/null

#################################

exit "$OK"

