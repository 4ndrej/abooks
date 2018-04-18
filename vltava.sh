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

wget -q $1 -O $TMPFILE

FILENAME=$(\
    cat $TMPFILE \
    | grep og:title \
    | sed -e "s/.*content=\"//g" -e "s/\" .*//g" -e "s/\. *\(.*\)/ (\1)/g" \
    | tr -d "\"" \
    | tr ":\?\!/" "----" \
    | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g"\
)
ID=$(
    cat $TMPFILE \
    | grep filename \
    | grep -v rights-expired \
    | sed -e "s/.*a href=\"//g" -e "s/\?uuid.*//g"\
)

IDS=(${ID// / })
RIADKOV=${#IDS[@]}

if [[ $RIADKOV -eq 0 ]]; then
    FILENAME=$(\
        cat $TMPFILE \
        | grep "><h1>" \
        | grep image \
        | grep title \
        | sed -e "s/.*<h1>//g" -e "s/<\/h1>.*//g" \
        | tr -d "\"" \
        | tr ":\?\!/" "----" \
        | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g" \
        | head -n 1\
    )
    ID=$(\
        cat $TMPFILE \
        | grep player-archive \
        | sed -e "s/.*a><a href=\"http:\/\/prehravac.rozhlas.cz\/audio\//http:\/\/media.rozhlas.cz\/_audio\//g" -e "s/\" title.*//g" \
        | head -n 1\
    )
    # echo "Filename: $FILENAME"
    echo "ID/URL: $ID"
    wget $WGET_PARAMS -q $ID -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
elif [[ $RIADKOV -eq 1 ]]; then
    # echo "Filename: $FILENAME"
    echo "ID/URL: $ID"
    wget $WGET_PARAMS -q $ID -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
else
    echo $RIADKOV zaznamov
    TITLE_ALL=$(\
        cat $TMPFILE \
        | grep filename \
        | grep -v rights-expired \
        | sed -e "s/.*title=\"//g" -e "s/\">.*//g" \
        | tr -d "\"" \
        | tr ":\?\!/" "----" \
        | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g"\
    )
    IFS=$'\n' TITLES=(${TITLE_ALL})

    for INDEX in "${!IDS[@]}"
    do
        RIADOK=$(( 1 + $INDEX ))
        ID=${IDS[INDEX]}
        FILENAME=${TITLES[INDEX]}-$((INDEX+1))
        # FILENAME2=$(echo $FILENAME \($RIADOK z $RIADKOV\) | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
        # echo "Filename: $FILENAME"
        echo "ID/URL: $ID"
        wget $WGET_PARAMS -q $ID -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
        # id3v2 --track $RIADOK/$RIADKOV $FILENAME.mp3 >/dev/null 2>&1
        echo
    done
fi

rm $TMPFILE
