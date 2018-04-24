#!/bin/bash
# vltava audio books grabber
# blame on andrej@gmail.com

# input http://www.rozhlas.cz/vltava/stream/_zprava/karel-capek-komisar-mejzlik-zasahuje--1421447
# output wget http://media.rozhlas.cz/_audio/1421447.mp3 -O Karel\ Čapek\ -\ Komisař\ Mejzlík\ zasahuje.mp3

if [[ $# -lt 1 ]]; then
    echo "chybny pocet parametrov"
    echo "takto: $0 http://vltava.rozhlas.cz/edgar-wallace-kriminalni-pribehy-johna-g-reedera-36-zamilovany-policista-5346045"
    exit 1
fi

WGET_PARAMS="-nc"

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

wget -q "$1" -O "$TMPFILE"

FILENAME=$( \
    < "$TMPFILE" \
    grep og:title \
    | sed -e "s/.*content=\"//g" -e "s/\" .*//g" -e "s/\. *\(.*\)/ (\1)/g" \
    | tr -d "\"" \
    | tr ":\?\!/" "----" \
    | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g" \
)
ID=$( \
    < "$TMPFILE" \
    grep filename \
    | grep -v rights-expired \
    | sed -e "s/.*a href=\"//g" -e "s/\?uuid.*//g" \
)

IDS=(${ID// / })
RIADKOV=${#IDS[@]}

if [[ $RIADKOV -eq 0 ]]; then
    FILENAME=$( \
        < "$TMPFILE" \
        grep "><h1>" \
        | grep image \
        | grep title \
        | sed -e "s/.*<h1>//g" -e "s/<\/h1>.*//g" \
        | tr -d "\"" \
        | tr ":\?\!/" "----" \
        | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g" \
        | head -n 1 \
    )
    ID="$( \
            < "$TMPFILE" \
            grep player-archive \
            | sed -e "s/.*a><a href=\"http:\/\/prehravac.rozhlas.cz\/audio\//http:\/\/media.rozhlas.cz\/_audio\//g" -e "s/\" title.*//g" \
            | head -n 1 \
    )"
    if [[ $ID == "" ]]; then
        # sem fallbackne aj multifile stranka ktora ma vsetky zaznamy expirovane
        echo ziadny zaznam na stiahnutie
    else
        # echo "Filename: $FILENAME"
        echo "ID/URL: $ID"
        wget "$WGET_PARAMS" -q "$ID" -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
    fi
# elif [[ $RIADKOV -eq 1 ]]; then
#     # echo "Filename: $FILENAME"
#     echo "ID/URL: $ID"
#     wget "$WGET_PARAMS" -q "$ID" -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
else
    ITERATOR=$( \
        < "$TMPFILE" \
        grep a-004b__iterator \
        | sed -e 's|.*">\(.*\)</span.*|\1|g' \
    )
    TITLE_EXPIRED=$( \
        < "$TMPFILE" \
        grep filename \
        | grep rights-expired \
        | sed -e "s/.*/~/g" \
    )
    TITLE_EXPIRED_ARR=(${TITLE_EXPIRED// / })
    TITLE_EXPIRED_COUNT=${#TITLE_EXPIRED_ARR[@]}

    echo "$TITLE_EXPIRED_COUNT expirovanych zaznamov"
    echo "$RIADKOV dostupnych zaznamov"
    TITLE_VALID=$( \
        < "$TMPFILE" \
        grep filename \
        | grep -v rights-expired \
        | sed -e "s/.*title=\"//g" -e "s/\">.*//g" \
        | tr -d "\"" \
        | tr ":\?\!/" "----" \
        | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g" \
    )
    IFS=$'\n' TITLES=(${TITLE_EXPIRED} ${TITLE_VALID})
    ITERATORS=(${ITERATOR// / })

    # for INDEX in "${!IDS[@]}"
    for INDEX in "${!ITERATORS[@]}"
    do
        # skip expired links (indicated by TITLE == ~)
        if [[ ${TITLES[INDEX]} == '~' ]]; then
            echo "preskakujem expirovany zaznam ${ITERATORS[INDEX]}"
            continue
        fi
        ID=${IDS[INDEX-TITLE_EXPIRED_COUNT]}
        FILENAME="${TITLES[INDEX]} - ${ITERATORS[INDEX]}"
        # echo "Filename: $FILENAME"
        echo "ID/URL: $ID"
        wget "$WGET_PARAMS" -q "$ID" -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
        # RIADOK=$(( 1 + $INDEX ))
        # id3v2 --track $RIADOK/$RIADKOV $FILENAME.mp3 >/dev/null 2>&1
        echo
    done
fi

rm "$TMPFILE"
