import os
import mutagen
import re
import sys
import shutil

from mutagen.oggvorbis import OggVorbis


def _print_warning(*args):
    msg = ' '.join(str(x) for x in args)
    print(msg, file=sys.stderr)

if len(sys.argv) < 2:
    print('Usage:', sys.argv[0], 'oggfile [..]]')
    sys.exit(1)

# Regex
re_artist_title = r'(.+) - (.+).ogg'
re_artist_title = re.compile(re_artist_title)

re_title_info = r'(.+) ?(\(.*\))'
re_title_info = re.compile(re_title_info)

# Start
for ogg_file in sys.argv[1:]:
    if not os.path.isfile(ogg_file):
        _print_warning(f'{ogg_file} is not a file')
        continue

    file_abspath = os.path.abspath(ogg_file)
    file_dirname = os.path.dirname(file_abspath)
    file_basename = os.path.basename(file_abspath)

    try:
        # Open the Ogg file using Mutagen's OggVorbis class
        audio = OggVorbis(file_abspath)
    except mutagen.oggvorbis.OggVorbisHeaderError:
        print('Not an ogg vorbis file', file=sys.stderr)
        continue

    artist_title_match = re_artist_title.fullmatch(file_basename)
    artist = artist_title_match[1]
    title = artist_title_match[2]

    if ', The' == artist[-5:]:
        artist_sort = artist
        artist = 'The ' + artist[:-5]
    elif 'The ' in audio['artist'][-5:]:
        artist_sort = audio['artist']
        artist = 'The ' + audio['artist'][:-5]
    elif 'The ' == artist[:4]:
        artist_sort = artist[4:] + ', The'
    elif 'The ' in audio['artist'][:4]:
        artist_sort = audio['artist'][4:] + ', The'
    else:
        artist_sort = None

    if ')' == title[-1] or ')' == audio['title'][-1]:
        if ')' == title[-1]:
            artist_title_match = re_title_info.fullmatch(title)
        else: # if ')' == audio['title'][-1]:
            artist_title_match = re_title_info.fullmatch(audio['title'])

        if artist_title_match is not None:
            title = artist_title_match[1].strip()
            info = artist_title_match[2].strip()
            info = info[1:-1]
        else:
            info = None
    else:
        info = None

    audio['artist'] = artist
    audio['title'] = title
    if artist_sort:
        audio['artistsort'] = artist_sort
    if info:
        audio['info'] = info
    audio.save()

    new_name = artist_sort if artist_sort else artist
    new_name += ' - ' + title
    if info:
        new_name += ' (' + info + ')'
    new_name += '.ogg'

    new_abspath = os.path.join(file_dirname, new_name)

    if file_abspath != new_abspath:
        print(file_abspath, '->', new_abspath)
        shutil.move(file_abspath, new_abspath)