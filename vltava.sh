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

# FILENAME=$(cat $TMPFILE | tr "<" "\n" | grep "data-title=" | head -n 1 | sed -e "s/ data-url.*//g" -e "s/.*data-title=//g" | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
# if grep -Fxq audio-play-all $TMPFILE
#   then
#     echo "normal id"
#     ID=$(cat $TMPFILE | grep publication_id | sed -e "s/.* //g" -e "s/,.*//g")
#   else
#     echo "audiobook id"
#     ID=$(cat $TMPFILE | grep "audio-play-all" | sed -e "s/.*audio\///g" -e "s/\".*//g")
# fi

# http://vltava.rozhlas.cz/sites/default/files/audios/wallace_edgar_-_kriminalni_pribehy_j._g._reedera_3.mp3?uuid=58e695e17d54e

FILENAME=$(cat $TMPFILE | grep h2 | grep element-invisible | sed -e 's/.*a href=".*">//g' -e "s/(do .*)//g" -e "s/\. .*//g" | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
ID=$(cat $TMPFILE | grep audios | sed -e "s/.*a href=\"//g" -e "s/\?uuid.*//g")

echo "Filename: $FILENAME"
echo "ID/URL: $ID"
# echo "URL: http://media.rozhlas.cz/_audio/$ID.mp3"

rm $TMPFILE

# wget -q http://media.rozhlas.cz/_audio/$ID.mp3 -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "error"
wget -q $ID -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "error"
