#!/usr/bin/env bash

BING_API="https://www.bing.com/HPImageArchive.aspx"
API_PARMS="format=xml&idx=0&n=1"
LOOP=true
DAEMON=true
RUN=true
DEST="$(xdg-user-dir PICTURES)/BingWallpaper"

usage() { 
    echo "Usage: $0 [-d <string>]" 1>&2 
    echo
    echo "  -d  Destination directory of images"
    echo "  -h  Display this help message."
    echo "      Default: ${DEST}"
    echo
    exit 1
}

while getopts "d:h" o; do
    case "${o}" in
        d)
            DEST=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

mkdir -p ${DEST}

image_url() {
    # $1 => XML
    # $2 => Resolution
    if [[ $2 ]]; then
        echo "$(echo $1 | sed 's/.*<urlBase>\([^ ]*\)<\urlBase>.*/\1/')_${2}.jpg"
    fi
        echo "$(echo $1 | sed 's/.*<url>\([^ ]*\)<\url>.*/\1/' | cut -d '&' -f 1 )"
}

file_name() {
    local DATE=$(echo $1 | sed 's/.*<startdate>\([^ ]*\)<\/startdate>.*/\1/')
    echo "${DATE}-$(echo $BING_IMAGE_URN | cut -d . -f2-)"

}

apply_backgroud() {
    gsettings set org.gnome.desktop.background picture-uri "file:///${DEST}/${1}"
    gsettings set org.gnome.desktop.screensaver picture-uri "file:///${DEST}/${1}"
}

loop() {
    while ${RUN}; do
        local RESP_XML=$(wget -q -O- '${BING_API}?${API_PARMS}')
        if [[ $? -eq 0 ]]; then
            local IMAGE_NAME=$(file_name $RESP_XML)
            if [[ ! -f "${DEST}/${IMAGE_NAME}" ]]; then
                wget -q -O "${DEST}/${IMAGE_NAME}" "https://www.bing.com$(image_url $RESP_XML)"
                if [[ $? -eq 0 ]]; then
                    apply_backgroud $IMAGE_NAME
                fi
            fi
        fi
        if ${LOOP}; then
            sleep 3h
        else
            RUN=false
        fi
    done
}

if ${DAEMON}; then
    loop > /dev/null 2>&1 &
else
    loop
fi
