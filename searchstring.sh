#!/bin/bash
AAPT_PATH="./aapt"

if [ $# -gt 3 -o $# -lt 2 ]; then
    echo "$0 the.apk <resource number (hex OR decimal)>"
    DIE=1
fi
#http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# > 0 ]]; do
    if [ -z "$APK_PATH" ]; then
        APK_PATH=$1
    elif [ -z $RESOURCE ]; then
        RESOURCE=$1
        if [ "${RESOURCE:0:2}" == "0x" ]; then
            HEX=1
        fi
    fi
    shift
done

AAPT_PATH=$(echo $(cd $(dirname "$AAPT_PATH") && pwd -P)/$(basename "$AAPT_PATH"))
APK_PATH=$(echo $(cd $(dirname "$APK_PATH") && pwd -P)/$(basename "$APK_PATH"))
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

if [ -z "$HEX" ]; then
    "$AAPT_PATH" d --values resources "$APK_PATH" | grep -v "spec " | grep -A1 $(printf "0x%x" $RESOURCE) | tail -1 | awk -F \" '{print $2}'
else
    "$AAPT_PATH" d --values resources "$APK_PATH" | grep -v "spec " | grep -A1 $RESOURCE | tail -1 | awk -F \" '{print $2}'
fi
