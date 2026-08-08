#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
Remove all tags but artist and title from given file. Only tested with Vorbis
files.

Will make an attempt of capitalising letters properly.
"""

import mutagen
import os
import sys

# Tags of interest
INFO = 'info'  # Extra parenthesized information (e. g. live, cover, etc.)
TITLE = 'title'  # Name of track
ARTIST = 'artist'  # Name of artist or band
ARTISTSORT = 'artistsort'  # Sortable name of artist (e. g. 'Beatles, The' and 'Lennon, John')


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

    lower_cased = ('a', 'an', 'and', 'as', 'at', 'but', 'for', 'nor', 'of', 'or', 'the', 'to', 'by')

    cap = first_word or word not in lower_cased
    if cap:
        word = word.capitalize()

    if lparent:
        word = f'({word}'
    if rparent:
        word = f'{word})'

    return word


def initialism(word):
    """
    >>> initialism('ramones')
    'ramones'
    >>> initialism('raMONes')
    'raMONes'
    >>> initialism('r.a.m.o.n.e.s.')
    'R.A.M.O.N.E.S.'
    >>> initialism('Ramones.')
    'Ramones.'
    >>> initialism('t.ex.')
    't.ex.'
    """
    period = '.'
    if period in word:
        letters = word.split(period)
        if 2 * len(letters) == len(word) + 2:
            word = word.upper()

    return word


def capitalise(lang: str, tag: str) -> str:
    """
    Capitalise tag according to lang option

    >>> capitalise('', ' the mAn in A cave OF Love ')
    'the mAn in A cave OF Love'
    >>> capitalise('e', 'the mAn in A cave OF Love')
    'The Man In a Cave of Love'
    >>> capitalise('s', 'the Man In A Cave OF Love')
    'The man in a cave of love'
    >>> capitalise('', 'it´s a Man In A Cave OF Love')
    "it's a Man In A Cave OF Love"
    >>> capitalise('e', 'it´s a Man In A Cave OF Love')
    "It's a Man In a Cave of Love"
    >>> capitalise('s', 'it´s a Man In A Cave OF Love')
    "It's a man in a cave of love"
    >>> capitalise('e', 'it´s a Man In A Cave OF Love')
    "It's a Man In a Cave of Love"
    """
    capitalised = tag
    if not tag:
        pass

    elif lang == 'e':
        words = tag.split()
        word = words[0]
        word = parent(word, True)
        capitalised = word

        for word in words[1:]:
            word = word.lower()
            word = parent(word, False)
            word = initialism(word)
            capitalised += f' {word}'

    elif lang == 's':
        words = tag.split()
        capitalised = words[0].capitalize()
        capitalised += ' ' + ' '.join(x.lower() for x in words[1:])

    capitalised = capitalised.strip()
    sanitised = translate_characters(capitalised)
    return sanitised


def translate_characters(sentence):
    sentence = sentence.replace("´", "'")
    sentence = sentence.replace("’", "'")
    sentence = sentence.replace('…', '...')
    return sentence


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
                print(f'{arg} is not a mutagen.File')
                continue
            elif ARTIST not in file:
                print(f'Artist tag is missing from {arg}')
                continue
            elif TITLE not in file:
                print(f'Title tag is missing from {arg}')
                continue

            changed = False
            for tag in file:
                if tag not in (ARTIST, TITLE, ARTISTSORT, INFO):
                    print(f'{arg}: Remove tag {tag}')
                    file.pop(tag)
                    changed = True
                elif tag == INFO:
                    # Keep as is
                    pass
                else:
                    before = file[tag][0]
                    after = capitalise(lang, before)
                    file[tag][0] = after
                    if before != after:
                        changed = True
                        print(f'{before} -> {after}')

            artist = file[ARTIST][0]
            artist_split = artist.split(' ')
            if artist_split[0] == 'The':
                artistsort = ' '.join(artist_split[1:]) + ', The'
                if ARTISTSORT not in file:
                    file[ARTISTSORT] = []
                file[ARTISTSORT][0] = artistsort
                changed = True

            elif artist_split[0] == 'A':
                artistsort = ' '.join(artist_split[1:]) + ', A'
                if ARTISTSORT not in file:
                    file[ARTISTSORT] = []
                file[ARTISTSORT][0] = artistsort
                changed = True

            if ARTISTSORT in file:
                if ((ARTIST in file and file[ARTISTSORT] == file[ARTIST])
                    or (not file[ARTISTSORT][0].strip())):
                    file.pop(ARTISTSORT)
            
            # Save tags
            file.save()

            # Move if changed
            if not changed:
                basename = os.path.basename(arg)
                at = basename.split(' - ', 1)
                if len(at) == 2:
                    artist = at[0]
                    title = at[1].rsplit('.')[0]

                    changed = (artist == file[ARTIST][0]) or (title == file[TITLE][0])

            if changed:
                # New filename
                ext = arg.split('.')[-1]

                artist = file[ARTIST][0] 
                if ARTISTSORT in file and file[ARTISTSORT][0]:
                    artist = file[ARTISTSORT][0] 
                title = file[TITLE][0]

                info = ''
                if INFO in file:
                    info = ' ({})'.format(file[INFO][0])  # note the space

                artist_split = artist.split(' ')
                if artist_split[0] == 'The':
                    artist = ' '.join(artist_split[1:]) + ', The'
                    file[ARTISTSORT][0] = artist

                filename =  f'{artist} - {title}{info}.{ext}' 

                if filename != arg:
                    answer = ''
                    while answer not in ('y', 'n'):
                        answer = input(f'Move {arg} to {filename}? [y/n]').lower()
                    if answer == 'y':
                        try:
                            if os.path.exists(filename):
                                print(f'{filename} already exist. Will not overwrite.')
                            else:
                                os.rename(arg, filename)
                        except OSError:
                            print(f'Could not write to {filename}.')


if '__main__' == __name__:
    main()
