"""
Menat to run ever so often to log how many song by artist X is available in the
current MPD playlist.

Load and store from JSON file.

TODO: Assert the same playlist is used
"""
import os
import sys
import time

import argparse
import json
import matplotlib.pyplot as plt
import musicpd

# Constans
HOME = os.getenv('HOME')
FILE_NAME = '.mpd_graph.json'

FILE = os.path.join(HOME, '.mpd_graph.json')
FILE = os.path.abspath(FILE)


def generate_graph(data: dict) -> None:
    """ Generate graph with matplot """

    x_data = list(data.keys())
    labels = list(data[x_data[0]].keys())

    y_values = {}
    for stime in data:
        for artist in data[stime]:
            if artist not in y_values:
                y_values[artist] = []
            y_values[artist].append(data[stime][artist])

    for artist in labels:
        len_x, len_y = len(x_data), len(y_values[artist])

        if len_x > len_y:
            y_values[artist] += [0] * (len_x - len_y)

        if len_x < len_y:
            print('This should never happen')
            continue

        plt.plot(x_data, y_values[artist], label=artist)

    plt.legend()
    plt.show()


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
        artist = song['artist']
        if artist not in data[now]:
            data[now][artist] = 0
        data[now][artist] += 1

    client.close()
    client.disconnect()

    return data


def save_json(data: dict) -> None:
    """ Save new data into json file. """
    with open(FILE, 'w', encdoing='UTF-8') as file:
        json.dump(data, file)


def load_json() -> dict:
    """ Read data from json file. """
    data = {}

    if not os.path.exists(FILE):
        print(f'{FILE} does not exist. Create empty.', file=sys.stderr)
        with open(FILE, 'w', encoding='UTF-8') as file:
            file.close()

    with open(FILE, 'r', encoding='UTF-8') as file:
        content = file.read()
        # Should this really be necessary?
        if not content:
            content = '{}'

    data = json.loads(content)
    return data


def main(show_graph: bool = False) -> None:
    """ Do everything """
    # Load JSON file content
    data = load_json()

    if not show_graph:
        # Read data from MPD into dictionary
        data = read_mpd(data)

        # Save data to JSON
        save_json(data)

    else:
        generate_graph(data)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--graph', default=False, const=True,
                        action='store_const',
                        help='Wether to just show a graph')
    args = parser.parse_args()
    main(args.graph)
