#!/bin/bash

cd ~/musik

for i in {9..2}; do
    find . -name "* ($i).ogg" -type f | \
        grep -v ^./.osorterat | \
        while read old; do 
            TO=$(($i-1))
            for j in $(seq 1 $TO); do 
                new=$(echo "$old" | sed "s/ ($i).ogg/ ($j).ogg/")
                if ! [ -f "$new" ]; then
                    INSERT=$(echo $new | sed "s/\.\///")
                    echo $INSERT
                    mv -v "$old" "$new"
                    mpc insert "$INSERT"
                fi
            done
        done
    done

    find . -name "* (1).ogg" -type f | \
        grep -v ^./.osorterat | \
        while read old; do 
            new=$(echo "$old" | sed "s/ ($i).ogg/.ogg/")
            if ! [ -f "$new" ]; then
                INSERT=$(echo $new | sed "s/\.\///")
                echo $INSERT
                mv -v "$old" "$new" && mpc insert "${new%./}"
            fi
        done

        exit 0
