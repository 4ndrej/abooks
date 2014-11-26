#!/bin/bash
# vltava audio books grabber
# blame on andrej@gmail.com

# input http://www.rozhlas.cz/vltava/stream/_zprava/karel-capek-komisar-mejzlik-zasahuje--1421447
# output wget http://media.rozhlas.cz/_audio/1421447.mp3 -O Karel\ Čapek\ -\ Komisař\ Mejzlík\ zasahuje.mp3

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

wget -q $1 -O $TMPFILE

FILENAME=$(cat $TMPFILE | tr "<" "\n" | grep "data-title=" | head -n 1 | sed -e "s/ data-url.*//g" -e "s/.*data-title=//g" | tr -d "\"" | tr ":\?\!" "---" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
ID=$(cat $TMPFILE | tr "<" "\n" | grep "player-article" | head -n 1 | sed -e "s/.*player-article-//g" -e "s/\" class=\"uniplayer\".*//g" )

rm $TMPFILE

wget -q http://media.rozhlas.cz/_audio/$ID.mp3 -O "$FILENAME.mp3"

