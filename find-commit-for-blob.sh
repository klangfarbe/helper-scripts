#! /bin/sh
#
#  set these:
searchfor=$1

startpoints="${2:-master}"  # branch names or HEAD or whatever
# you can use rev-list limiters too, e.g., origin/master..master

git rev-list $startpoints |
    while read commithash; do
        if git ls-tree -r --full-tree $commithash | grep $searchfor; then
            echo " -- found at $commithash"
        fi
    done

