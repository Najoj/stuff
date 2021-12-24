#!/usr/bin/env python3
#-*- coding:utf-8 -*-

"""
Remove all tags but artist and title from given file. Only works for Vorbis
files.
"""

import sys
import mutagen


def capitalise(lang: str, tag: str) -> str:
    """
    Capitalise tag according to lang option

    >>> capitalise('', 'the mAn in A cave OF Love')
    'the mAn in A cave OF Love'
    >>> capitalise('e', 'the mAn in A cave OF Love')
    'The Man In a Cave of Love'
    >>> capitalise('s', 'the Man In A Cave OF Love')
    'The man in a cave of love'
    """
    capitalised = tag

    if lang == 'e':
        words = tag.split()
        capitalised = words[0].capitalize()
        for word in words[1:]:
            word = word.lower()
            if word not in ('of', 'the', 'a', 'an', '(feat'):
                if word[0] == '(':
                    word = '(' + word[1:].capitalize()
                else:
                    word = word.capitalize()
            capitalised += f' {word}'

    elif lang == 's':
        words = tag.split()
        capitalised = words[0].capitalize()
        capitalised += ' ' + ' '.join(x.lower() for x in words[1:])

    return capitalised.strip()


def main():
    """
    Main method
    """
    if len(sys.argv) < 2:
        sys.exit(0)

    lang = ''
    for arg in sys.argv[1:]:
        if arg == '-s':
            lang = 's'
        elif arg == '-e':
            lang = 'e'
        else:
            file = mutagen.File(arg)
            if not file:
                continue

            for tag in file:
                if tag not in ('artist', 'title'):
                    print(f'{arg}: Remove tag {tag}')
                    file.pop(tag)
                else:
                    file[tag] = capitalise(lang, file[tag][0])
            file.save()


if '__main__' == __name__:
    main()

