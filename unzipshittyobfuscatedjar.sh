#!/bin/bash
if [ ! -f "$1" ]; then
    echo $i does not exist
    exit
fi
if [ -z "$2" ]; then
    outdir="out"
else
    outdir="$2"
fi
if [ -d "$outdir" ]; then
    echo "Directory $outdir exists"
    exit
fi
mkdir "$outdir"
unzip -l "$1" | tail -n +4 | sed '$d' | sed '$d' | awk '{print $4}' | while read i;
do
    dir=`dirname "$outdir/$i"`
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
    if [ "${i: -1}" == "/" ];then
        continue
    fi
    if [ -f "$outdir/$i" ]; then
        unzip -p "$1" "$i" > "$outdir/$RANDOM-$i"
    else
        unzip -p "$1" "$i" > "$outdir/$i"
    fi
done
