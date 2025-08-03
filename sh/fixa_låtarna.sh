#!/usr/bin/env bash

cd /media/musik/ || exit 1

for i in {9..2}; do
find . -name "* ($i).ogg" -type f | \
        grep -v ^./.osorterat | \
        while read -r old; do
                TO=$((i-1))
                for j in $(seq 1 $TO); do
                        new="${old% ("$i").ogg} ($j).ogg"
                        if ! [ -f "$new" ]; then
                                INSERT="${new#./}"
                                echo "$INSERT"
                                mv -nv "$old" "$new"
                                mpc -qw update
                                mpc add "$INSERT"
                        fi
                done
        done

        find . -name "* (1).ogg" -type f | \
                grep -v ^./.osorterat | \
                while read -r old; do
                        new="${old%' (1).ogg'}.ogg"

                        if ! [ -f "$new" ]; then
                                INSERT="${new#./}"
                                echo insert "$INSERT"
                                mv -nv "$old" "$new"
                                mpc -qw update
                                mpc add "$INSERT"
                        fi
                done
        done
