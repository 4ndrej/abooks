# pirating russian pirates with joy
# https://www.goldenmp3.ru/compilations/electro-mode-an-electro-tribute-to-depeche-mode
wget -q $1 -O - \
    | sed -e 's/\(<a class="play"\)/\n\nSNIP1\0/g' \
    | sed -e 's/<span itemprop="name">\([a-zA-Z0-9 ]*\)<\/span>/SNIP2\0SNIP3\n\n/g' \
    | grep SNIP \
    | sed -e 's/SNIP1.*rel="\([0-9a-f]+\)".*<td>/\0;/g' \
    | sed -e 's/SNIP1.*rel="//g' -e 's/" title.*wrap">/;/g' -e 's/\.&ensp.*name">/;/g' -e 's/<\/span.*//g' \
    | sed -e 's|\([-;0-9a-f]*\);\([-;0-9]*\);\(.*\)|wget https://listen.musicmp3.ru/\1  -O "\2. \3.mp3" --referer="https://www.goldenmp3.ru/compilations/electro-mode-an-electro-tribute-to-depeche-mode" -U "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.88 Safari/537.36"|g'\
    | bash