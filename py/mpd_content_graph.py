"""
Menat to run ever so often to log how many song by artist X is available in the
current MPD playlist.

Load and store from JSON file.

TODO: Assert that the same playlist is used
"""

import json
import sys
import argparse
import os
import time
import musicpd

# Constans
HOME = os.getenv('HOME')
FILE_NAME = '.mpd_graph.json'

FILE = os.path.join(HOME, '.mpd_graph.json')
FILE = os.path.abspath(FILE)

def read_mpd(data: dict) -> dict:
    # Get current timestamp
    now = int(time.time())
    if now not in data:
        data[now] = dict()

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
    with open(FILE, 'w') as file:
        json.dump(data, file)

def load_json() -> dict:
    data = dict()

    if not os.path.exists(FILE):
        print(f'{FILE} does not exist. Create empty.', file=sys.stderr)
        open(FILE, 'w').close()

    with open(FILE, 'r') as file:
        content = file.read()
        # TODO: Should this really be necessary?
        if not content:
            content = '{}'

    data = json.loads(content)
    return data


def main(show_graph: bool = False) -> None:
    # Load JSON file content
    data = load_json()

    if not show_graph:
        # Read data from MPD into dictionary 
        data = read_mpd(data)

        # Save data to JSON
        save_json(data)

    else:
        # TODO: Generate graph
        # generate_graph(data)
        print('Not yet implemented', file=sys.stderr)

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--graph', default=False, const=True,
            action='store_const',
            help='Wether to just show a graph')
    args = parser.parse_args()
    main(args.graph)

