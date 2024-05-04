#!/bin/bash
command -v mpc > /dev/null || exit 1

DIR="/media/musik"
SHUFFLE="true"
OSORT="false"
# 
TMP="$(mktemp)"
FORD="${HOME}/.fördelade"
FRAM="${HOME}/.framflyttade"
# Exit status
((OK=0))
# Limit to get an artist directory
((DIRLIMIT=8))
# Playlist limit
((LIMIT=16000+I))

#################################
#  Uppdaterar.                  #
#################################

echo ================================================================================
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

echo ================================================================================
echo -n "Börjar med att säkerhetskopiera spellistan: "
spellista="säkerhetskopia-$(date +%s)"
echo "\"${spellista}\"" 
mpc -wq update || exit 1
mpc -w save "$spellista"  || exit 1

cd "$DIR" || exit 1

#################################

if $OSORT; then
        echo ================================================================================
        echo -n "Undersöker .osorterat-mappen... "
        _LEN=$(find "${DIR}/.osorterat/" -maxdepth 1 -type f -and \( -name "*.flac" -or -name "*.ogg" \) | wc -l)
        if [ 0 = "$_LEN" ]; then
                echo "den är tom." 
        else
                echo "den är inte tom."
                LIMITA=$(( 2*(LIMIT-LENGTH) / 3))
                LIMITB=$((LIMIT-LENGTH-LIMITA))

                # äldst
                echo "Lägger till $LIMITA gamla filer." 
                cd "${DIR}/.osorterat/" || exit 1

                find . -maxdepth 1 -type f -printf "%A@ %p\\n" -type f -and \( -name "*.flac" -or -name "*.ogg" \) \
                        | sort -n | cut -d\  -f2- | head -n "$LIMITA" \
                        | while read -r track; do
                        mv -v "${track}" "${DIR}"   && \
                        mpc -qw update              && \
                        mpc -w add "${track#./}"
                done | cat -n

                # populära artister
                echo "Lägger till $LIMITB filer på måfå." 
                cd "${DIR}/.osorterat/" || exit 1
                find . -maxdepth 1 -type f -and \( -name "*.flac" -or -name "*.ogg" \) \
                        | shuf | tail -n $LIMITB | while read -r track; do
                        mv -v "${track}" "${DIR}"   && \
                        mpc -qw update              && \
                        mpc -w add "${track#./}"
                done | cat -n
        fi
fi

################################

cd "$DIR" || exit 1
echo ================================================================================
echo "Flyttar på band som börjar med \"The\"." 
find . -maxdepth 1 -type f -name 'The *' -a '(' -name '*\.flac' -o -name '*\.ogg'  ')' | \
while read -r band; do
        newband="${band#./The }" 
        newband="${newband// - /, The - }"
        mv -v "${band}" "${newband}"    && \
        mpc -wq update                  && \
        mpc -w add "${newband#./}"
done

# Directories
find . -maxdepth 1 -type d -name 'The *' | \
while read -r dir; do
        newdir="${dir#./The }, The"
        mv -v "${dir}" "${newdir}"  && \
        mpc -wq update              && \
        mpc -w add "${newdir#./}"
done

#################################

cd "$DIR" || exit 1
echo ================================================================================
echo "Undersöker om några band redan har mappar."
find . -maxdepth 1 -type f -name \*" - "\* | sed -E 's/ - .+//' | sort -u | \
while read -r band; do
        if ls -d "${band}/" &> /dev/null ; then
                mv -v "${band} - "* "${band}/"
                cd "${band}" || break
                # Remove inital ./
                band=${band#./}
                find . -name "${band} - "\* | sed -E 's/.+ - //' | \
                while read -r title; do
                        mv -v "${band} - ${title}" "${title}"   && \
                        mpc -wq update                          && \
                        mpc -w add "${band#./}/${title}"
                done
        fi
        cd "$DIR" || exit 2
done

#################################

cd "$DIR" || exit 1
echo ================================================================================
echo "Undersöker om några band ska ha mappar."
find . -maxdepth 1 -name \*" - "\* -type f | \
    grep -Ev '.(omslag|spellistor|osorterat|torrenter)' | \
    sed 's/ - /\n/' | grep -Ev "\\.(ogg|flac)"$ | sort -g | uniq  | \
while read -r band; do
        N=$(find . -maxdepth 1 -name "${band#./} - *\\.*" -type f | wc -l)
        if [ "$N" -ge "$DIRLIMIT" ]; then
                first=true
                grep -Ev "${band}" "${FORD}" > "${TMP}" && mv "$TMP" "$FORD"
                grep -Ev "${band}" "${FRAM}" > "${TMP}" && mv "$TMP" "$FRAM"
                mkdir "${band}"
                mv -v "${band} - "* "${band}/"
                cd "${band}" || exit 1
                find . -maxdepth 1 -type f | while read -r bandtitle; do
                        title="${bandtitle#"${band}" - }"
                        mv -v "${bandtitle}" "${title}"     && \
                        mpc -wq update
                        if $first; then
                                mpc -w insert "${band#./}/${title}"
                                first=false
                        else
                                mpc -w add "${band#./}/${title}"
                        fi

                done
        fi
        cd "$DIR" || exit 2
done

#################################

cd "$DIR" || exit 2
echo ================================================================================
echo "Undersöker om några låtar ska nedgraderas."
find . -maxdepth 1 -type d -and -not -name '.*' -and -not -path "./lost+found" | \
while read -r band; do
        cd "${band}" || continue
        N=$(find . -maxdepth 1 -type f -name "*.*" 2> /dev/null | wc -l)
        if ! ls ./*/ &> /dev/null && [ "$N" -lt "$DIRLIMIT" ]; then
                first=true
                grep -Ev "${band}" "${FORD}" > "${TMP}" && mv "$TMP" "$FORD"
                grep -Ev "${band}" "${FRAM}" > "${TMP}" && mv "$TMP" "$FRAM"
                find . -maxdepth 1 -type f -name "*.*" 2> /dev/null | \
                cut -c 3- | \
                while read -r title; do
                        mv -uv "${title}" ../"${band} - ${title#./}"    && \
                        mpc -wq update
                        if $first; then
                                mpc -w insert "${band#./}/${title}"
                                first=false
                        else
                                mpc -w add "${band#./}/${title}"
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

