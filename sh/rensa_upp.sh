#!/bin/bash

which mpc > /dev/null || exit 1

DIR="/media/musik"
LIM=8
SHUFFLE="true"
OSORT="false"
LIMIT=15000

#################################
#  Uppdaterar.                  #
#################################

echo -n "uppdaterar databas..."
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
                                echo "Spellistan är över $LIMIT. Rens!"
                                exit 1 || OSORT="false"
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

echo -n " === Börjar med att säkerhetskopiera spellistan: "
spellista="säkerhetskopia-$(date +%s)"
echo "\"${spellista}\" ==="
mpc -wq update || exit 1
mpc -w save "$spellista"  || exit 1

cd "$DIR" || exit 1

#################################

if $OSORT; then
        echo -n " === Undersöker .osorterat-mappen... "
        if [ 0 = "$(find "${DIR}/.osorterat/" -type f -and \( -name "*.flac" -or -name "*.ogg" \) | wc -l)" ]; then
                echo "den är tom. ==="
        else
                echo "den är inte tom."
                LIMITA=$(( (LIMIT-LENGTH) / 2))
                LIMITB=$((LIMIT-LENGTH-LIMITA))

                # äldst
                echo "Lägger till $LIMITA gamla filer. ==="
                cd "${DIR}/.osorterat/" || exit 1

                find . -type f -and \( -name "*.flac" -or -name "*.ogg" \) \
                        | tr -s ' ' | sort -gr -k6 | tail -n $LIMITA \
                        | while read -r track; do
                        mv -v "${track}" "${DIR}"    && \
                        mpc -qw update                && \
                        mpc -w add "${track#./}"
                done | cat -n

                # populära
                echo "Lägger till $LIMITB filer på måfå. ==="
                cd "${DIR}/.osorterat/" || exit 1
                find . -type f -and \( -name "*.flac" -or -name "*.ogg" \) \
                        | shuf | tail -n $LIMITB | while read -r track; do
                        echo -n "$i. " && let i++
                        mv -v "${track}" "${DIR}"    && \
                        mpc -qw update                && \
                        mpc -w add "${track#./}"
                done
        fi
fi

################################

cd "$DIR" || exit 1
echo " === Flyttar på band som börjar med \"The\". ==="
find . -maxdepth 1 -type f -name 'The *' -a '(' -name '*\.flac' -o -name '*\.ogg'  ')' | \
while read -r band; do
        newband="${band#./The }" 
        newband="${newband// - /, The - }"
        mv -v "${band}" "${newband}"   && \
        mpc -wq update                  && \
        mpc -w add "${newband}"
done

find . -maxdepth 1 -type d -name 'The *' | \
while read -r dir; do
        newdir="${dir#./The }, The"
        mv -v "${dir}" "${newdir}"         && \
        mpc -wq update                      && \
        mpc -w add "${newdir}"
done

#################################

cd "$DIR" || exit 1
echo " === Undersöker om några band redan har mappar. ==="
find . -name \*" - "\* | sed 's/ - /\n/' | \
        grep -Ev "\.(ogg|flac)"$ | sort -g | uniq  | \
while read -r band; do
        if ls -d "${band}/" &> /dev/null ; then
                mv -v "${band} - "* "${band}/" && \
                cd "${band}"                    && \
                find . -name "${band} - "\* | sed 's/ - /\n/' | grep -E "\.(ogg|flac)"$ | sort -g | \
                while read -r title; do
                        mv -v "${band} - ${title}" "${title}"   && \
                        mpc -wq update                  && \
                        mpc -w add "${band}/${title}"
                done
        fi
        cd "$DIR" || exit 2
done

#################################

cd "$DIR" || exit 1
echo " === Undersöker om några band ska ha mappar. ==="
find . -name \*" - "\* -type f | grep -Ev '.(omslag|spellistor|osorterat|torrenter)' | \
sed 's/ - /\n/' | grep -Ev "\.(ogg|flac)"$ | sort -g | uniq  | \
while read -r band; do
        N=$(find . -name "${band} - *\.*" -type f | wc -l)
        if [ "$N" -ge "$LIM" ]; then
                echo "$band  $N"
                mkdir "${band}"
                mv -v "${band} - "* "${band}/"
                cd "${band}" || exit 1
                find . -maxdepth 1 | while read -r bandtitle; do
                        title=${bandtitle#${band} - }
                        mv -v "${bandtitle}" "${title}"   && \
                        mpc -wq update                 && \
                        mpc -w add "${band}/${title}"
                done
        fi
        cd "$DIR" || exit 2
done

#################################

cd "$DIR" || exit 2
echo " === Undersöker om några låtar ska nedgraderas. ==="
find . -type d -maxdepth 1 | sed 's/\///' | \
while read -r band; do
        echo $band
        if find . -type d -name "${band}" -maxdepth 1 &> /dev/null ; then
                cd "${band}" || exit 2
                N=$(find . -maxdepth 1 -type f -name "*.*" 2> /dev/null | wc -l)
                if ! (ls -d ./*/ &> /dev/null || [ "$N" -ge $LIM ] ); then
                        find . -maxdepth 1 -name "*.*" 2> /dev/null | \
                        while read -r title; do
                                mv -uv "${title}" ../"${band} - ${title}"   && \
                                mpc -wq update                              && \
                                mpc -w add "${band} - ${title}"
                        done
                fi
        fi
        cd "$DIR" || exit 2
        rmdir "${band}" 2> /dev/null
done

#################################

eval "$SHUFFLE" > /dev/null

#################################

echo "Klar!"

exit 0
