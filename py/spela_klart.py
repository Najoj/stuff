#!/usr/bin/env python3
# -*- coding:utf-8 -*-

from musicpd import MPDClient

import os
import sys
import time


def printTime(t):
    # Time in minutes and rest
    tm = int(t/60)
    ts = int(t % 60)

    # Return strings
    ps = str(tm)

    # If 0 needs to be appended
    if tm < 10:
        ps = '0' + ps

    ps += ':'

    if ts < 10:
        ps += '0' + str(ts)
    else:
        ps += str(ts)

    return ps + ' \r'


def main():
    client = MPDClient()
    host = os.getenv('MPD_HOST', 'localhost')
    port = os.getenv('MPD_PORT', '6600')
    port = int(port)
    client.connect(host, port)

    currentTrack = client.status()['songid']
    while currentTrack == client.status()['songid']:
        t = int(float(client.currentsong()[
                'time']) - float(client.status()['elapsed']))
        print(printTime(t), end='\r')
        sys.stdout.flush()
        time.sleep(0.25)

    client.close()
    client.disconnect()

    print('00:00')

    return 0


if __name__ == '__main__':
    sys.exit(main())
