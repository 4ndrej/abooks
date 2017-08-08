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

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

wget -q $1 -O $TMPFILE

FILENAME=$(cat $TMPFILE | grep og:title | sed -e "s/.*content=\"//g" -e "s/\" .*//g" -e "s/\. *\(.*\)/ (\1)/g" | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
ID=$(cat $TMPFILE | grep filename | sed -e "s/.*a href=\"//g" -e "s/\?uuid.*//g")

IDS=(${ID// / })
RIADKOV=${#IDS[@]}

if [[ $RIADKOV -lt 2 ]]; then
  # echo "Filename: $FILENAME"
  echo "ID/URL: $ID"
  wget -q $ID -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "$FILENAME.mp3 ERROR"
else
  echo $RIADKOV zaznamov

  for INDEX in "${!IDS[@]}"
  do
    RIADOK=$(( 1 + $INDEX ))
    ID=${IDS[INDEX]}
    FILENAME2=$(echo $FILENAME \($RIADOK z $RIADKOV\) | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
    # echo "Filename: $FILENAME2"
    echo "ID/URL: $ID"
    wget -q $ID -O "$FILENAME2.mp3" && echo "$FILENAME2.mp3 OK" || echo "$FILENAME2.mp3 ERROR"
    echo
  done
fi

rm $TMPFILE
