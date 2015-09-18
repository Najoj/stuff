#!/bin/bash

which mpc > /dev/null || exit 1

DIR="/media/musik"
LIM=8
SHUFFLE="true"
OSORT="false"

#################################
#  Rensar upp i min musikmapp.  #
#################################

for arg in $@; do
    case "$arg" in
        "-o")
            RENS=9999
            if [ $(mpc playlist | wc -l) -gt $RENS ]; then
                echo "Spellistan är över $RENS. Rens!"
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

mpc -w update || exit -1337

echo -n " === Börjar med att säkerhetskopiera spellistan: "
spellista="säkerhetskopia-$(date +%s)"
echo \"${spellista}\"" ==="
mpc -w update > /dev/null || exit 1
mpc -w save "$spellista"  || exit 1

cd "$DIR"

#################################

if $OSORT; then
    echo -n " === Undersöker .osorterat-mappen... "
    if [ 0 = $(find "${DIR}/.osorterat/" -type f -name \*\.ogg | wc -l) ]; then
        echo "den är tom. ==="
    else
        LIMIT=$(( 10000 - $(mpc playlist | wc -l) ))
        [ $LIMIT -lt 0 ] && LIMIT=0
        
        echo "den är inte tom. Lägger till högst $LIMIT filer. ==="
        cd "${DIR}/.osorterat/"         && \
        ls *\.ogg | shuf | head -n $LIMIT | while read ogg; do
            mv -uv "${ogg}" "${DIR}"    && \
            mpc -w update > /dev/null   && \
            mpc -w add "${ogg#./}"
        done
    fi
fi

################################

cd "$DIR"
echo " === Flyttar på band som börjar med \"The\". ==="
ls -d The\ *\ -\ *.*  2> /dev/null | \
while read band; do
    newband=$(echo "${band#The }" | sed s/' - '/', The - '/)
    mv -uv "${band}" "${newband}"   && \
    mpc -w update > /dev/null       && \
    mpc -w add "${newband}"
done
ls -d The\ */ 2> /dev/null | sed 's/\///' | \
while read dir; do 
    newdir="$(echo "${dir#The }, The")" && \
    mv -uv "${dir}" "${newdir}"         && \
    mpc -w update > /dev/null           && \
    mpc -w add "${newdir}"
done

#################################

cd "$DIR"
echo " === Undersöker om några band redan har mappar. ==="
ls *" - "* | sed 's/ - /\n/' | egrep -v "\.(ogg|flac)$" | sort -g | uniq  | \
while read band; do
    if ls -d "${band}/" &> /dev/null ; then
        mv -uv "${band} - "* "${band}/" && \
        cd "${band}"                    && \
        ls "${band} - "* | sed 's/ - /\n/' | egrep "\.(ogg|flac)$" | sort -g | \
        while read title; do
            mv -uv *"${title}" "${title}"   && \
            mpc -w update > /dev/null       && \
            mpc -w add "${band}/${title}"
        done
    fi
    cd "$DIR" || exit 2
done

#################################

cd "$DIR"
echo " === Undersöker om några låtar ska ha mappar. ==="
ls *" - "* | sed 's/ - /\n/' | egrep -v "\.(ogg|flac)$" | sort -g | uniq  | \
while read band; do
    N=$(ls "${band} -"* | wc -l)
    if [ "$N" -ge "${LIM}" ]; then
        mkdir "${band}"
        mv -uv "${band} - "* "${band}/"
        cd "${band}"
        ls "${band} - "* | sed 's/ - /\n/' | egrep "\.(ogg|flac)$" | sort -g | \
        while read title; do
            mv -v *"${title}" "${title}"   && \
            mpc -w update > /dev/null       && \
            mpc -w add "${band}/${title}"
        done
    fi
    cd "$DIR" || exit 2
done

#################################

cd "$DIR"
echo " === Undersöker om några låtar ska få nedgraderas. ==="
ls -d */ | sed 's/\///' | \
while read band; do
    if ls -d "${band}/" &> /dev/null ; then
        cd "${band}"
        N=$(ls *.ogg *.flac 2> /dev/null | wc -l)
        if ! ls -d */ &> /dev/null && [ "$N" -lt "${LIM}" ]; then
            ls *.ogg *.flac 2> /dev/null | \
            while read title; do
                mv -uv "${title}" ../"${band} - ${title}"   && \
                mpc -w update > /dev/null                   && \
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
