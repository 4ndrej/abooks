# pirating russian pirates with joy
# https://www.goldenmp3.ru/compilations/electro-mode-an-electro-tribute-to-depeche-mode

if [[ $# -lt 1 ]]; then
    echo "chybny pocet parametrov"
    echo "takto: $0 https://www.goldenmp3.ru/depeche-mode/shake-the-disease"
    exit 1
fi

TMPFILE=$(mktemp) || { echo "Failed to create temp file"; exit 1; }

wget -q $1 -O $TMPFILE

# album folder
ALBUM_FOLDER=$( \
    cat $TMPFILE \
        | sed \
            -e 's|.*sub_span2" itemprop="name">\(.*\)</span></h1>.*itemprop="datePublished">\(.*\)</span></p>.*|\2. \1|g' \
            -e 's|&amp;|\&|g' \
)
echo Creating $ALBUM_FOLDER
mkdir "$ALBUM_FOLDER"
cd "$ALBUM_FOLDER"

# album cover file
cat $TMPFILE \
    | sed -e 's|.*\(https://files.musicmp3.ru/bcovers/alb[0-9]*\.jpg\).*|wget -c -O cover.jpg \1|g' \
    | bash

# music files
cat $TMPFILE \
    | sed \
        -e 's|<tr |\n<tr |g' \
        -e 's|</tr>|</tr>\n|g' \
    | grep "<tr" \
    | grep "Listen the song" \
    | sed \
        -e 's|<tr.*rel="||g' \
        -e 's|" title="Listen.*td_wrap">|;|g' \
        -e 's|&ensp;<span itemprop="name">| |g' \
        -e 's|</span>.*||g' \
        -e 's|&amp;|\&|g' \
    | sed \
        -e 's|\(.*\);\(.*\)|wget -c https://listen.musicmp3.ru/\1 --referer="https://www.goldenmp3.ru/compilations/electro-mode-an-electro-tribute-to-depeche-mode" -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.88 Safari/537.36" -O "\2.mp3"|g' \
    | bash

rm $TMPFILE
echo $ALBUM_FOLDER done.
cd -
