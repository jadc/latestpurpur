#!/bin/sh
MC_VERSION='1.18.1'
JAR='server.jar'

URL="https://api.purpurmc.org/v2/purpur/$MC_VERSION/latest"
LATEST_API="$(curl -s $URL)"

upgrade() {
    echo 'Downloading latest Purpur...'
    curl -s "$URL/download" -o $JAR \
        && echo ' successfully downloaded latest Purpur' \
        || echo ' failed to download latest Purpur'
}

check_for_update(){
    echo Checking for updates...
    OLD_HASH="$(md5sum $JAR | awk '{print $1}')"
    NEW_HASH="$(echo $LATEST_API | jq -r '.md5')"
    [ $OLD_HASH = $NEW_HASH ] && echo ' there are no new updates' && exit

    # Verify if build was even successful
    BUILD_RESULT="$(echo $LATEST_API | jq '.result')"
    [ "$BUILD_RESULT" = "\"FAILURE\"" ] && echo ' latest build is marked failure, aborting' && exit

    echo ' there is a new successful build available'
    rm $JAR && upgrade
}

[ -e $JAR ] && check_for_update || upgrade
