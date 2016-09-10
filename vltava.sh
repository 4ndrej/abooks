#!/bin/bash
# vltava audio books grabber
# blame on andrej@gmail.com

# input http://www.rozhlas.cz/vltava/stream/_zprava/karel-capek-komisar-mejzlik-zasahuje--1421447
# output wget http://media.rozhlas.cz/_audio/1421447.mp3 -O Karel\ Čapek\ -\ Komisař\ Mejzlík\ zasahuje.mp3

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

wget -q $1 -O $TMPFILE

FILENAME=$(cat $TMPFILE | tr "<" "\n" | grep "data-title=" | head -n 1 | sed -e "s/ data-url.*//g" -e "s/.*data-title=//g" | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
if grep -Fxq audio-play-all $TMPFILE
  then
    echo "normal id"
    ID=$(cat $TMPFILE | grep publication_id | sed -e "s/.* //g" -e "s/,.*//g")
  else
    echo "audiobook id"
    ID=$(cat $TMPFILE | grep "audio-play-all" | sed -e "s/.*audio\///g" -e "s/\".*//g")
fi

echo "Filename: $FILENAME"
echo "ID: $ID"
echo "URL: http://media.rozhlas.cz/_audio/$ID.mp3"

rm $TMPFILE

wget -q http://media.rozhlas.cz/_audio/$ID.mp3 -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "error"
