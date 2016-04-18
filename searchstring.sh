#!/bin/bash
AAPT_PATH="./aapt"


AAPT_PATH=$(echo $(cd $(dirname "$AAPT_PATH") && pwd -P)/$(basename "$AAPT_PATH"))
APK_PATH=$(echo $(cd $(dirname "$1") && pwd -P)/$(basename "$1"))
if [ $# -ne 2 ]; then
    echo "$0 apk <resource number (decimal)>"
    DIE=1
fi
if [ ! -f "$AAPT_PATH" ]; then
    echo "aapt cannot be found, edit AAPT_PATH with the correct path"
    DIE=1
fi
if [ ! -f "$APK_PATH" ]; then
    echo "the apk cannot be found"
    DIE=1
fi
if [ ! -z $DIE ]; then
    exit
fi

"$AAPT_PATH" d --values resources "$APK_PATH" | grep -v "spec " | grep -A1 $(printf "0x%x" $2) | tail -1 | awk -F \" '{print $2}'
