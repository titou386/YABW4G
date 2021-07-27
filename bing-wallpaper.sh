#!/usr/bin/env bash

DEST="$(xdg-user-dir PICTURES)/BingWallpaper"
mkdir -p ${DEST}
loop2fork() {
    while :
    do
        RESP_XML=$(wget -q -O- 'https://www.bing.com/HPImageArchive.aspx?format=xml&idx=0&n=1')
        if [[ $? -eq 0 ]]; then
            BING_IMAGE_URN=$(echo $RESP_XML | sed -e 's/<[^>]*>//g' | cut -d / -f2 | cut -d \& -f1)
            DATE=$(echo $RESP_XML | sed 's/.*<startdate>\([^ ]*\)<\/startdate>.*/\1/')
            IMAGE_NAME="${DATE}-$(echo $BING_IMAGE_URN | cut -d . -f2-)"
            if [[ ! -f "${DEST}/${IMAGE_NAME}" ]]; then
                wget -q -O "${DEST}/${IMAGE_NAME}" "https://www.bing.com/${BING_IMAGE_URN}"
                if [[ $? -eq 0 ]]; then
                    gsettings set org.gnome.desktop.background picture-uri "file:///${DEST}/${IMAGE_NAME}"
                    gsettings set org.gnome.desktop.screensaver picture-uri "file:///${DEST}/${IMAGE_NAME}"
                fi
            fi
        fi
        sleep 3h
    done
}

loop2fork &
