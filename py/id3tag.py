#!/usr/bin/env python3
#-*- coding:utf-8 -*-

"""
Remove all tags but artist and title from given file.

TODO: Adjust capitalisation of artist and titel. Have to figure out which
language the title is in that case.
"""

import sys
import mutagen

if len(sys.argv) < 2:
    sys.exit(0)

for arg in sys.argv[1:]:
    file = mutagen.File(arg)
    if not file:
        continue

    for tag in file:
        if tag not in ('artist', 'title'):
            print(f'{arg}: Remove tag {tag}')
            file.pop(tag)
    file.save()
