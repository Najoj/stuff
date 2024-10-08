#!/usr/bin/env python3
# -*- coding:utf-8 -*-

"""
Rolling song title from MPD based on elapsed song playing time.
"""

# for arguments
import sys
# MPD
from musicpd import MPDClient

# Total width
LENGTH = 26
# Divider when exceeding limit
DIVIDER = '   '


def parser(client, title_string):
    """ Replaces each key with value, iff it exists. """
    for key in client.currentsong().keys():
        try:
            replace_with = str(client.currentsong()[str(key)])
            title_string = str.replace(
                title_string, "%" + key + "%", replace_with)
        except TypeError:
            title_string = str.replace(title_string, "%" + key + "%", "")
            continue
    return title_string


def main():
    """ Plain main function. """
    if len(sys.argv) == 1:
        print("You will have to give an argument.", file=sys.stderr)
        return 1
    # If nothing fails.
    return_value = 0
    try:
        # Connect to the MPD server
        client = MPDClient()
        client.connect("localhost", 6600)
        client.socket_timeout = 10 # seconds
        title_string = parser(client, str(sys.argv[1]))

    except TypeError:
        # Failure. Probably unable to connect to the MPD server.
        return_value = 1
        title_string = "Could not connect to the MPD server"

    #print( int( client.status()['time'].split(':')[0] ) )

    # If we have to cut dow the string or not
    if LENGTH >= len(title_string):
        # Have to append input, if it is shorter than LENGTH
        len_diff = LENGTH - len(title_string)
        append_before = (' ') * int((len_diff/2))
        append_after = (' ') * int((len_diff/2) + 0.5)

        # Prints and flushes the output
        print(append_before + title_string + append_after)
        # print(title_string)
        sys.stdout.flush()

    else:
        # Keep track of where to cut the long title string
        start = int(client.status()['time'].split(':')[0]) % (
            len(title_string) + len(DIVIDER))
        end = start+LENGTH

        # Appends to the title_string, so that we can roll-over easily
        title_string = title_string + DIVIDER + title_string

        print(title_string[start:end])
        sys.stdout.flush()

    # Closing the connection.
    client.close()
    client.disconnect()

    # Done!
    return return_value


if __name__ == '__main__':
    sys.exit(main())
