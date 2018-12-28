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

mpc -w update || exit 1

#################################
#  Rensar upp i min musikmapp.  #
#################################

for arg in $@; do
    case "$arg" in
        "-o")
            if [ $(mpc playlist | wc -l) -ge $LIMIT ]; then
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
echo \"${spellista}\"" ==="
mpc -wq update || exit 1
mpc -w save "$spellista"  || exit 1

cd "$DIR"

#################################

if $OSORT; then
    echo -n " === Undersöker .osorterat-mappen... "
    if [ 0 = $(ls "${DIR}/.osorterat/"*\.{flac,ogg} | wc -l) ]; then
        echo "den är tom. ==="
    else
        LIMIT=$(( LIMIT - $(mpc playlist | wc -l) ))
        [ $LIMIT -le 0 ] && LIMIT=0
        let i=1;
        echo "den är inte tom. Lägger till högst $LIMIT filer. ==="
        cd "${DIR}/.osorterat/"         && \
        ls *\.{ogg,flac} | shuf | head -n $LIMIT | while read track; do
            echo -n "$i. " && let i++
            mv -uv "${track}" "${DIR}"    && \
            mpc -qw update                && \
            mpc -w add "${track#./}"
        done
    fi
fi

################################

cd "$DIR"
echo " === Flyttar på band som börjar med \"The\". ==="
find . -maxdepth 1 -type f -name 'The *' -a '(' -name '*\.flac' -o -name '*\.ogg'  ')' | \
while read band; do
    newband=$(echo "${band#./The }" | sed 's/ - /, The - '/)
    mv -uv "${band}" "${newband}"   && \
    mpc -wq update                  && \
    mpc -w add "${newband}"
done

find . -maxdepth 1 -type d -name 'The *' | \
while read dir; do 
    newdir="$(echo "${dir#./The }, The")" && \
    mv -uv "${dir}" "${newdir}"         && \
    mpc -wq update                      && \
    mpc -w add "${newdir}"
done

#################################

cd "$DIR"
echo " === Undersöker om några band redan har mappar. ==="
ls *" - "* | sed 's/ - /\n/' | egrep -v "\.(ogg|flac)"$ | sort -g | uniq  | \
while read band; do
    if ls -d "${band}/" &> /dev/null ; then
        mv -uv "${band} - "* "${band}/" && \
        cd "${band}"                    && \
        ls "${band} - "* | sed 's/ - /\n/' | egrep "\.(ogg|flac)"$ | sort -g | \
        while read title; do
            mv -uv "${band} - ${title}" "${title}"   && \
            mpc -wq update                  && \
            mpc -w add "${band}/${title}"
        done
    fi
    cd "$DIR" || exit 2
done

#################################

cd "$DIR"
echo " === Undersöker om några band ska ha mappar. ==="
ls *" - "* | sed 's/ - /\n/' | egrep -v "\.(ogg|flac)"$ | sort -g | uniq  | \
while read band; do
    N=$(ls "${band} - "*\.* | wc -l)
    if [ $N -ge $LIM ]; then
    echo $band  $N
        mkdir "${band}"
        mv -uv "${band} - "* "${band}/"
        cd "${band}"
        ls | while read bandtitle; do
            title=${bandtitle#${band} - }
            mv -v "${bandtitle}" "${title}"   && \
            mpc -wq update                 && \
            mpc -w add "${band}/${title}"
        done
    fi
    cd "$DIR" || exit 2
done

#################################

cd "$DIR"
echo " === Undersöker om några låtar ska nedgraderas. ==="
ls -d */ | sed 's/\///' | \
while read band; do
    if ls -d "${band}/" &> /dev/null ; then
        cd "${band}"
        N=$(ls *.* 2> /dev/null | wc -l)
        if ! ( ls -d */ &> /dev/null || [ $N -ge $LIM ] ); then
            ls *.* 2> /dev/null | \
            while read title; do
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
