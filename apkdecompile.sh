#!/bin/bash
JAD_PATH="./jad"
DEX2JAR_PATH="./d2j-dex2jar.sh"

#http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# > 0 ]]; do
    key="$1"

    case $key in
        -f|--force)
            FORCE="--force"
        ;;
        *)
            if [ -z $APK_NAME ]; then
                APK_NAME=$key
            else
                echo "Unknown arg $key"
                DIE=1
            fi
        ;;
    esac
    shift
done

JAD_PATH=$(echo $(cd $(dirname "$JAD_PATH") && pwd -P)/$(basename "$JAD_PATH"))
DEX2JAR_PATH=$(echo $(cd $(dirname "$DEX2JAR_PATH") && pwd -P)/$(basename "$DEX2JAR_PATH"))

if [ -z "$APK_NAME" ]; then
    echo "Specify APK as an argument"
    DIE=1
fi
if [ ! -f "$DEX2JAR_PATH" ]; then
    echo "Dex2jar cannot be found, edit DEX2JAR_PATH with the correct path"
    DIE=1
fi
if [ ! -f "$JAD_PATH" ]; then
    echo "JAD cannot be found, edit JAD_PATH with the correct path"
    DIE=1
fi

if [ ! -z $DIE ]; then
    exit
fi

"$DEX2JAR_PATH" -o out.jar $FORCE "$APK_NAME"
if [ -d out -a -z "$FORCE" ]; then
    echo "out dir exists and force not specified, exiting"
    exit
fi

rm -rf out &>/dev/null
mkdir out
echo "extracting and decompiling..."
unzip -qd out out.jar
find out -name "*.class" -execdir "$JAD_PATH" -o {} \; 2>/dev/null
