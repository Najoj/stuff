#!/bin/bash

case $(date +%m) in
    03|04|05)
        N=4
        ;;
    06|07|08)
        N=5
        ;;
    09|10|11)
        N=6
        ;;
    12|01|02)
        N=7
        ;;
    *)
        N=1
esac

echo -n \$\{color${N}\}\$\{time \%b\}\$\{color\}
