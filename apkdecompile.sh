#!/bin/bash
JAD_PATH="/Users/Cheddar/Dev/jad/jad"
DEX2JAR_PATH="/Users/Cheddar/Dev/dex2jar/d2j-dex2jar.sh"

#http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
while [[ $# > 0 ]]; do
    key="$1"

    case $key in
        -f|--force)
            FORCE="--force"
        ;;
        -s|--shitty)
            SHITTY=1
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
    echo "You can use the --shitty/-s option to unzip a jar with class names that clash. You can tell this is the case if this program asks you to overwrite files... This option was created because I got pissed off at non-case-sensitive filesystems"
    exit
fi

"$DEX2JAR_PATH" -o out.jar $FORCE "$APK_NAME"
if [ -d out -a -z "$FORCE" ]; then
    echo "out dir exists and force not specified, exiting"
    exit
fi

rm -rf out &>/dev/null
mkdir out
if [ -z "$SHITTY" ]; then
    echo "Extracting"
    unzip -qd out out.jar
else
    echo "Doing long and painful extraction due to duplicate names"
    outdir="out"
    unzip -l out.jar | tail -n +4 | sed '$d' | sed '$d' | awk '{print $4}' | while read i;
    do
        dir=`dirname "$outdir/$i"`
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
        fi
        if [ "${i: -1}" == "/" ];then
            continue
        fi
        if [ -f "$outdir/$i" ]; then
            newname=`echo $i | sed "s/\.class$/-$RANDOM.class/"`
            unzip -p "out.jar" "$i" > "$outdir/$newname"
        else
            unzip -p "out.jar" "$i" > "$outdir/$i"
        fi
    done
fi
echo "Decompiling"

for i in `find out -name "*.class"`; do
    outfile=`echo $i | sed "s/\.class$/.jad/"`
    "$JAD_PATH" -p "$i" 1>"$outfile" 2>/dev/null
done
