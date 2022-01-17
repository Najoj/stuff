#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
To do: Warn about non-existing tags
"""

# MPD
from musicpd import MPDClient

import time  # sleep
import sys  # argument
import os   # environment variables

# Total width
LENGTH = int(os.getenv('ROLLINGSIZE', '60'))
# Divider when exceeding limit
DIVIDER = "    "
# Time step between outputs
WAIT_TIME = 0.99    # seconds


def parser(client, title_string):
    # Replaces each key with value, iff it exists.
    for key in client.currentsong().keys():
        try:
            replace_with = str(client.currentsong()[str(key)])
            title_string = str.replace(
                title_string, "%" + key + "%", replace_with)
        except:
            continue
    return title_string


def main():
    # If nothing fails.
    return_value = 0
    try:
        # Connect to the MPD server
        client = MPDClient()
        client.connect("localhost", 6600)

        # Runs the script until a new songs comes on
        currentTrack = client.status()['songid']

        # If there is no argument, we will use  "artist - title"
        if 1 == len(sys.argv):
            title_string = parser(client, "%artist% - %title%")
        else:
            title_string = parser(client, str(sys.argv[1]))

    except:
        # Failure. Probably unable to connect to the MPD server.
        return_value = 1
        title_string = "Could not connect to the MPD server"

    # If we have to cut dow the string or not
    if LENGTH >= len(title_string):
        # Have to append input, if it is shorter than LENGTH
        len_diff = LENGTH - len(title_string)
        append_before = (' ') * int((len_diff/2))
        append_after = (' ') * int((len_diff/2) + 0.5)

        # Prints and flushes the output
        print(append_before + title_string + append_after)
        sys.stdout.flush()

        # Now we only have to wait.
        # while client.status()['songid'] == currentTrack:
        # time.sleep(WAIT_TIME)
    else:
        # Appends to the title_string, so that we can roll-over easily
        title_string = title_string + DIVIDER + title_string[0:LENGTH]

        # Keep track of where to cut the long title string
        start = 0
        end = LENGTH

        try:
            # While this song is playing
            while currentTrack == client.status()['songid']:
                # Print and flush
                print(title_string[start:end])
                sys.stdout.flush()
                # Wait a little bit
                time.sleep(WAIT_TIME)
                # Step through the string
                start += 1
                end += 1
                # We have are one lap through, so resert the steps
                if title_string[start:end] == title_string[0:LENGTH]:
                    start = 0
                    end = LENGTH
        except:
            # Something failed.
            return_value = 1

    # Closing the connection.
    client.close()
    client.disconnect()

    # Done!
    return return_value


if __name__ == '__main__':
    sys.exit(main())
