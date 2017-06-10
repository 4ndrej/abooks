#!/bin/bash
# rtvs archiv extra audio books grabber
# blame on andrej@gmail.com

# input http://www.rtvs.sk/radio/archiv/11453/702282
# output wget http://cdn.srv.rtvs.sk/a520/audio/00/0012/001229/00122982-1-DbHd.mp3 -O "O dvojhlavom drakovi.mp3"

if [[ $# -lt 1 ]]; then
  echo "chybny pocet parametrov"
  echo "takto: $0 http://www.rtvs.sk/radio/archiv/11453/702282"
  exit 1
fi

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

wget -q $1 -O $TMPFILE

FILENAME=$(cat $TMPFILE | grep "<h2>" | grep -v Archív | sed -e "s/.*<h2>//g" -e "s|</h2.*||g" | tr -d "\"" | tr ":\?\!/" "----" | sed -e "s/-/ - /g" -e "s/  / /g" -e "s/ $//g" -e "s/ /\\ /g")
PLAYLIST=$(cat $TMPFILE | grep playlist\" | sed -e "s/.*: \"//g" -e "s/&.*//g")

TMPFILE_PLAYLIST=$(mktemp) || { echo "Failed to create temp file"; exit 1; }
wget -q $PLAYLIST -O $TMPFILE_PLAYLIST

ID=$(cat $TMPFILE_PLAYLIST | grep file\" | sed -e "s/.*: \"//g" -e "s/\".*//g")

echo "Filename: $FILENAME"
echo "ID/URL: $ID"

rm $TMPFILE
rm $TMPFILE_PLAYLIST

wget -q $ID -O "$FILENAME.mp3" && echo "$FILENAME.mp3 OK" || echo "error"

