""" Find possible duplicates in MPD playlist. Only based on artist and file name. """

import os
import re
import sys
import random

import musicpd


class Song:
    def __init__(self, filename, _at_key, list_position):
        self.filename = filename
        self.at_key = _at_key
        self.position = list_position

    def __str__(self):
        return self.filename
    def __int__(self):
        return self.position

    def __eq__(self, other):
        return self.at_key == other.at_key

    def __repr__(self):
        return str(self)

def print_warning(message):
    print(message, file=sys.stderr)


def _whitelist(files: list) -> int:
    nof_whitelisted = 0
    with open(WHITELIST, 'a+') as _wl:
        for _file in files:
            _at_key = _file.at_key
            if DEBUG:
                print('whitelist', _at_key)
            _wl.write(_at_key)
            _wl.write(os.linesep)
            nof_whitelisted += 1
    return nof_whitelisted - len(files)

def _delete(files: list) -> int:
    _ogg = '.ogg'
    _flac = '.flac'
    nof_deleted = 0

    ogg_files = [f for f in files if str(f)[-len(_ogg):] == _ogg]
    flac_files = [f for f in files if str(f)[-len(_flac):] == _flac]
    sorted(flac_files, key=lambda x : x.position, reverse=False)

    client = musicpd.MPDClient()
    client.connect(host, port)
    for flac_file in flac_files:
        if DEBUG:
            print_warning('Delete: ' + flac_file.position)
        else:
            client.delete(flac_file.position)
    client.close()
    client.disconnect()

    for ogg_file in ogg_files:
        full_file = os.path.join(music_directory, str(ogg_file))
        if DEBUG:
            print_warning('Delete: ' + full_file)
        else:
            full_path = os.path.join(music_directory, ogg_file.filename)
            try:
                os.remove(full_path)
            except FileNotFoundError:
                print_warning(f'{full_path} was not found')

    return nof_deleted - len(files)

def sanitize(string: str) -> str:
    string = string.lower().replace(' and ', '').replace(' och ', '')
    string = re.sub('\W+', '', string, flags=re.U)
    return string

ASK = False
IGNORE_WHITELIST = False
if len(sys.argv) <= 2 and '--ask' in sys.argv[1:]:
    ASK = True
if len(sys.argv) <= 2 and '--ignore-wl' in sys.argv[1:]:
    IGNORE_WHITELIST = True

DEBUG = False
WHITELIST = os.path.join(os.getenv('HOME'), '.mpdups_whitelisted')
if os.path.exists(WHITELIST) and not IGNORE_WHITELIST:
    with open(WHITELIST) as wl:
        whitelisted = wl.readlines()
        whitelisted = [x.strip() for x in whitelisted]
        whitelisted = list(set(whitelisted))
        whitelisted.sort()

        # Randomly remove an element at random
        if ASK:
            random_int = random.randint(0, 9)
            if random_int == 0:
                random_element = random.choice(whitelisted)
                whitelisted.remove(random_element)

else:
    whitelisted = []

# Must be customised
_CONFIG_FILE=os.path.join(os.getenv('HOME'), '.mpdconf')
assert os.path.isfile(_CONFIG_FILE), f'Config file {_CONFIG_FILE} not found'

# get port, address, & music_directory
config = None
def get_from_config(setting: str, default=None) -> str:
    global config
    if config is None or not config:
        config = {}
        with open(_CONFIG_FILE, 'r') as config_file:
            for line in config_file.readlines():
                line_split = line.split('"')
                if len(line_split) >= 2:
                    key = line_split[0].strip()
                    val = line_split[1].strip()
                    config[key] = val
                else:
                    pass
                
    value = None
    if setting in config:
        value = config[setting]
    if value is None and default is None:
        raise ValueError('No value for {} in {}.'.format(setting, _CONFIG_FILE))
    if value is None:
        return default
    return value

music_directory = get_from_config('music_directory')
host = get_from_config('bind_to_address', 'localhost')
port = get_from_config('port', '6600')

assert music_directory is not None, f'No music directory found in {_CONFIG_FILE}'

# Connect to MPD
client = musicpd.MPDClient()
client.connect(host, port)
client.update(True)

all_songs = {}
for song in client.playlistinfo():
    artist = song['artist'] if 'artist' in song else None
    title = song['title'] if 'title' in song else None
    file = song['file'] if 'file' in song else None
    position = song['pos'] if 'pos' in song else None

    if artist is None or title is None or file is None or position is None:
        print_warning('Missing value:')
        print_warning(' artist:   ' + str(artist))
        print_warning(' song:     ' + str(title))
        print_warning(' file:     ' + str(file))
        print_warning(' position: ' + str(position))
    else:
        s_artist, s_title = sanitize(artist), sanitize(title)
        at_key = s_artist + '-' + s_title
        if file in all_songs and at_key not in whitelisted:
            print_warning(f'Duplicated file: {file}')
        else:
            if at_key not in all_songs:
                all_songs[at_key] = []
            all_songs[at_key].append(Song(file, at_key, position))

client.close()
client.disconnect()

for at_key in all_songs:
    delete = ''
    if len(all_songs[at_key]) > 1 and at_key not in whitelisted:
        print('These look the same:')
        i = 0
        for file in all_songs[at_key]:
            print(f'{i}. ', file)
            i += 1

        # Use of --ask flag
        if ASK:
            if DEBUG:
                delete = 'w0'
            else:
                try:
                    delete = input('Delete or whitelist? ')
                except (KeyboardInterrupt, EOFError):
                    break
            delete = delete.strip()

        elif len(delete) == 1 and delete[0] == 'q':
            break

        dw = ''
        num = 0
        if len(delete) >= 1:
            dw = delete[0]
        if len(delete) == 2:
            num = delete[1]
            try:
                num = int(num)
            except ValueError:
                print_warning(f'Invalid number: {num}')
                continue
            if num < 0 or i < num:
                print_warning(f'Invalid number: {num}')
                continue

        if dw == 'w':
            print('Will whitelist "' + at_key + '"')
            _whitelist([all_songs[at_key][num]])
        if dw == 'd':
            print('Will delete "' + str(all_songs[at_key][num]) + '"')
            _delete([all_songs[at_key][num]])
