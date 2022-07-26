#! /bin/sh

for x
do
    echo "Converting $x"
    f="tmp.`basename $x`"
    cat $x | tr -d '\015' > "$f"
    mv "$f" "$x"
done
