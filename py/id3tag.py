#!/usr/bin/env python3
#-*- coding:utf-8 -*-

"""
Remove all tags but artist and title from given file. Only tested with Vorbis
files.
"""

import mutagen
import os
import sys


def parent(word: str, first_word: bool) -> str:
    """
    Manages parenthised words

    >>> parent('(The', True)
    '(The'
    >>> parent('(The', False)
    '(the'
    >>> parent('Woman)', True)
    'Woman)'
    >>> parent('Woman)', False)
    'Woman)'
    >>> parent('The', True)
    'The'
    >>> parent('The', False)
    'the'
    >>> parent('(the)', True)
    '(The)'
    >>> parent('(the)', False)
    '(the)'
    """
    lparent, rparent = word[0] == '(', word[-1] == ')'

    if lparent:
        word = word[1:]
    if rparent:
        word = word[:-1]

    word = word.lower()

    lowercased = ('a', 'an', 'in', 'of', 'on', 'the', 'and', 'at')
    cap = first_word or word not in lowercased
    if cap:
        word = word.capitalize()

    if lparent:
        word = f'({word}'
    if rparent:
        word = f'{word})'

    return word


def capitalise(lang: str, tag: str) -> str:
    """
    Capitalise tag according to lang option

    >>> capitalise('', ' the mAn in A cave OF Love ')
    'the mAn in A cave OF Love'
    >>> capitalise('e', 'the mAn in A cave OF Love')
    'The Man in a Cave of Love'
    >>> capitalise('s', 'the Man In A Cave OF Love')
    'The man in a cave of love'
    >>> capitalise('', 'it´s a Man In A Cave OF Love')
    "it's a Man In A Cave OF Love"
    >>> capitalise('e', 'it´s a Man In A Cave OF Love')
    "It's a Man in a Cave of Love"
    >>> capitalise('s', 'it´s a Man In A Cave OF Love')
    "It's a man in a cave of love"
    """
    capitalised = tag

    if lang == 'e':
        words = tag.split()

        word = words[0]
        word = parent(word, True)
        capitalised = word

        for word in words[1:]:
            word = word.lower()
            word = parent(word, False)
            capitalised += f' {word}'

    elif lang == 's':
        words = tag.split()
        capitalised = words[0].capitalize()
        capitalised += ' ' + ' '.join(x.lower() for x in words[1:])

    return capitalised.strip().replace("´", "'")


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
            
            changed = False
            for tag in file:
                if tag not in ('artist', 'title'):
                    print(f'{arg}: Remove tag {tag}')
                    file.pop(tag)
                else:
                    before = file[tag][0]
                    after = capitalise(lang, before)
                    file[tag] = after
                    if before != after:
                        changed = True
                        print(f'{before} -> {after}')

            file.save()

            if changed:
                # New filename
                ext = arg.split('.')[-1]
                filename = file['artist'][0] + ' - ' + file['title'][0] + '.' + ext
                
                answer = ''
                while answer not in ('y', 'n'):
                    answer = input(f'Move {arg} to {filename}? [y/n]').lower()
                if answer == 'y':
                    try:
                        os.rename(arg, filename)
                    except os.OSError:
                        print(f'Could write to {filename}.')


if '__main__' == __name__:
    main()

