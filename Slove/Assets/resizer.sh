#!/bin/bash -e

# Ensure we're running in location of script.
#cd "`dirname $0`"

for f in *; do
  if [[ $f == *@3x* ]];
    then
    echo "$f -> ${f//@3x/@2x}, ${f//@3x/}"
    convert "$f" -resize 66.66666% "${f//@3x/@2x}"
    convert "$f" -resize 33.33333% "${f//@3x/}"
  fi
done

echo "Complete"