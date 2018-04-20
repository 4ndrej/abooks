# pirating russian pirates with joy
# now with categories meta downloader
# https://www.goldenmp3.ru/depeche-mode/remixes

if [[ $# -lt 2 ]]; then
    echo "chybny pocet parametrov"
    echo "takto: $0 category_prefix https://www.goldenmp3.ru/depeche-mode/remixes"
    exit 1
fi

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

PREFIX=$1
URL=$2

wget -q $URL -O $TMPFILE

cat $TMPFILE \
    | sed \
        -e 's|<a class="gr_names"|\n<a class="gr_names"|g' \
        -e 's|itemprop="url"|\nitemprop="url"|g' \
        -e 's|gr_names" href="\(.*\)" itemprop="url">|\1|g' \
    | grep gr_names \
    | sed -e 's|.*href="\(.*\)"|./goldenmp3.sh '$PREFIX' https://www.goldenmp3.ru\1; sleep 1m|g' \
    | sort -r \
    | bash

rm $TMPFILE
