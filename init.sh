#!/bin/bash

set -x

PWD=$(pwd)
SOURCE_FOLDER="$PWD/src"
IMAGES_LIST=($(ls $SOURCE_FOLDER))
for image in ${!IMAGES_LIST[@]}; do
    docker build -t autorecon_${IMAGES_LIST[$image]} -f ${SOURCE_FOLDER}/${IMAGES_LIST[$image]} .
done