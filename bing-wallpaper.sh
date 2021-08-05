#!/usr/bin/env bash

BING="https://www.bing.com"
BING_API="${BING}/HPImageArchive.aspx"
API_PARMS="format=xml&idx=0&n=1"
LOOP=true
DAEMON=false
RUN=true
DEST="$(xdg-user-dir PICTURES)/BingWallpaper"
HR="1920x1080"

usage() {
    echo
    echo "Usage: $0 [OPTION]" 1>&2 
    echo
    echo "  -1              Run once & quit"
    echo "  -d  DIRECTORY   Destination directory of images"
    echo "                    Default: ${DEST}"
    echo "  -h              Display this help message"
    echo "  -r              Enable high resolution"
    echo "  -x              Daemon mode"
    echo
    exit 1
}

while getopts "1d:hrx" options; do
    case "${options}" in
        1)
            LOOP=false
            ;;
        d)
            DEST=${OPTARG}
            ;;
        h)
            usage
            ;;
        r)
            HR='UHD'
            ;;
        x)
            DAEMON=true
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
    echo "$(echo $1 | sed 's/.*<urlBase>\([^ ]*\)<\/urlBase>.*/\1/')_${HR}.jpg"
}

file_name() {
    local DATE=$(echo $1 | sed 's/.*<startdate>\([^ ]*\)<\/startdate>.*/\1/')
    echo "${DATE}-$(echo ${2} | cut -d . -f2-)"

}

apply_backgroud() {
    gsettings set org.gnome.desktop.background picture-uri file:///${DEST}/${1}
    gsettings set org.gnome.desktop.screensaver picture-uri file:///${DEST}/${1}
}

loop() {
    while ${RUN}; do
        local RESP_XML=$(wget -q -O- "${BING_API}?${API_PARMS}")
        if [[ $? -eq 0 ]]; then
            local IMAGE_URL=$(image_url "${RESP_XML}")
            local IMAGE_NAME=$(file_name "${RESP_XML}" "${IMAGE_URL}")
            echo ${IMAGE_NAME}
            echo ${IMAGE_URL}
            if [[ ! -f ${DEST}/${IMAGE_NAME} ]]; then
                wget -q -O ${DEST}/${IMAGE_NAME} https://www.bing.com${IMAGE_URL}
                if [[ $? -eq 0 ]]; then
                    apply_backgroud "${IMAGE_NAME}"
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
