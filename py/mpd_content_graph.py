"""
Meant to run ever so often to log how many songs by artist X is available in the
current MPD playlist.

Load and store from JSON file.

TODO: Assert the same playlist is used
"""

import argparse
import sys
import datetime
import json
import os
import shutil
import time

import musicpd

# Constants
HOME = os.getenv('HOME')
FILE_NAME = '.mpd_graph.json'
ERROR_FILE_NAME = '.mpd_graph.log'

FILE = os.path.join(HOME, FILE_NAME)
FILE = os.path.abspath(FILE)

ERROR_FILE = os.path.join(HOME, ERROR_FILE_NAME)
ERROR_FILE = os.path.abspath(ERROR_FILE)


def print_warning(message, file=None):
    if file is None:
        file = ERROR_FILE

    with open(file, 'a') as f:
        f.write(message)
        f.write('\n')
    print(message, file=sys.stderr)


def from_epoch(epoch_time: int) -> str:
    time_ = int(epoch_time)
    return str(datetime.datetime.fromtimestamp(time_))


def all_bands(data: dict) -> list:
    bands = set()
    for key in data:
        bands |= set(data[key].keys())
    return list(bands)


def generate_graph(data: dict, range: int) -> None:
    """ Generate graph with matplot """
    if not data:
        print_warning('No data to plot.', file=ERROR_FILE)
        return

    import matplotlib.pyplot as plt
    import mplcursors

    timestamps = list(k for k in data.keys() if int(k) >= range)
    int_timestamps = list(map(int, timestamps))
    adjusted_timestamps = list(x - min(int_timestamps) for x in int_timestamps)

    labels = list(all_bands(data))

    y_values = {}
    for stime in data:
        if int(stime) < range:
            continue
        for artist in labels:
            if artist not in y_values:
                y_values[artist] = []

            if artist not in data[stime]:
                y_values[artist].append(0)
            else:
                y_values[artist].append(data[stime][artist])

    for artist in labels:
        if artist not in y_values:
            continue

        len_x, len_y = len(timestamps), len(y_values[artist])

        if len_x > len_y:
            print_warning('This should never happen. Diff between length of artist',
                          file=ERROR_FILE)
            y_values[artist] += [0] * (len_x - len_y)

        if len_x < len_y:
            print_warning('This should never happen.')
            continue

        plt.plot(adjusted_timestamps, y_values[artist], label=artist)

    timestamps_labels_tmp = list(map(from_epoch, int_timestamps))
    if len(timestamps_labels_tmp) > 1:
        timestamps_labels = [''] * len(timestamps_labels_tmp)
        timestamps_labels[0] = timestamps_labels_tmp[0]
        timestamps_labels[-1] = timestamps_labels_tmp[-1]

        plt.xticks(adjusted_timestamps, timestamps_labels, rotation=45)
        # Not sure how this works, but it does the job all right
        mplcursors.cursor(hover=True)
        plt.show()
    else:
        print('Not enough data to plot anything.', file=sys.stderr)


def read_mpd(data: dict) -> dict:
    """ Read data from MPD playlist """

    # Get current timestamp
    now = int(time.time())
    if now not in data:
        data[now] = {}

    # Connect to MPD
    host = os.getenv('MPD_HOST', 'localhost')
    port = int(os.getenv('MPD_PORT', '6600'))

    client = musicpd.MPDClient()
    client.connect(host, port)

    current_position = int(client.status()['song'])

    for song in client.playlistinfo()[current_position:]:
        if 'artist' not in song:
            print_warning('artist not in:' + str(song))
        else:
            artist = song['artist']
            if artist not in data[now]:
                data[now][artist] = 0
            data[now][artist] += 1

    client.close()
    client.disconnect()

    return data


def save_json(data: dict) -> None:
    """ Save new data into json file. """
    with open(FILE, 'w', encoding='UTF-8') as file:
        json.dump(data, file)


def load_json() -> dict:
    """ Read data from json file. """
    if not os.path.exists(FILE):
        print_warning(f'{FILE} does not exist. Create empty.', file=ERROR_FILE)
        with open(FILE, 'w', encoding='UTF-8') as file:
            file.close()

    with open(FILE, 'r', encoding='UTF-8') as file:
        content = file.read()

    if not content:
        content = '{}'

    data = json.loads(content)
    return data


def main(time_range: int) -> None:
    """ Do everything """
    # Load JSON file content
    data = load_json()

    show_graph = time_range > 0
    if show_graph:
        time_range = int(time.time() - time_range + 0.5)
        generate_graph(data, time_range)

    else:
        # Read data from MPD into dictionary
        data = read_mpd(data)
        # Save data to JSON
        save_json(data)


def _parse_arguments():
    global args
    parser_ = argparse.ArgumentParser()
    parser_.add_argument('--graph', default=False, type=str,
                         choices=['all', 'year', 'month', 'week', 'day'],
                         help='Weather to just show a graph')
    parser_.add_argument('--cleanup', default=False, const=True,
                         action='store_const',
                         help='Clean up in .json file')

    args = parser_.parse_args()
    return args


def _clean_up():
    original_file = FILE
    new_file = FILE + '.clean'
    backup_file = FILE + '.backup'

    shutil.copy(original_file, backup_file)

    with open(original_file, 'r') as f:
        original_content = json.load(f)

    with open(backup_file, 'w') as f:
        f.write(json.dumps(original_content))

    new_content = {}
    previous_key = None

    for key in original_content.keys():
        _content = original_content[key]
        if new_content:
            if _content == new_content[previous_key]:
                print_warning('Not adding ' + key)
            else:
                print_warning('Adding ' + key)
                new_content[key] = _content
                previous_key = key
        else:
            print_warning('First key: ' + key)
            new_content[key] = _content
            previous_key = key

    last_key = list(original_content.keys())[-1]
    if last_key not in new_content.keys():
        new_content[last_key] = original_content[last_key]


    with open(new_file, 'w') as f:
        f.write(json.dumps(new_content))

    shutil.copy(new_file, original_file)


if __name__ == '__main__':
    args = _parse_arguments()

    if args.cleanup:
        _clean_up()

    elif args.graph:
        time_ranges = {'none': 0,
                       'day': 24 * 60 * 60,
                       'week': 24 * 60 * 60 * 7,
                       'month': int(24 * 60 * 60 * 365.25 / 12),
                       'year': int(24 * 60 * 60 * 365.25),
                       'all': int(24 * 60 * 60 * 365.25) * 100}
        main(time_range=time_ranges[args.graph])
    else:
        main(0)
