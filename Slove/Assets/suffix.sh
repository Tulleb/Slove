for file in *.png; do
    mv "$file" "`basename $file .png`@3x.png"
done