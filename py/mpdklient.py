#!/usr/bin/env python3
#-*- coding:utf-8 -*-

# MPD
from musicpd  import MPDClient

import curses

import time
import sys

# Curses
def cursesdisconnect():
    try:
        curses.endwin()
    except:
        print("Kan inte släppa anslutningen till curses.", file=sys.stderr)
        sys.exit(1 + mpddisconnect())

def cursesconnect():
    try:
        screen = curses.inintscr()
    except:
        print("Kan inte starta curses.", file=sys.stderr)
        sys.exit(1 + mpddisconnect())

# MPD
def mpddisconnect():
    try:
        client.close()
        client.disconnect()
    except:
        print("Kan inte släppa anslutningen till MPD-servern.", file=sys.stderr)
        sys.exit(1)

def mpdconnect():
    try:
        client = MPDClient()
        client.connect("localhost", 6600)
    except:
        print("Kan inte ansluta till MPD-servern.", file=sys.stderr)
        sys.exit(1)

# Main
def main():
    mpdconnect()
    cursesconnect()

    cursesdisconnect()
    mpddisconnect()
    return 0

if __name__ == '__main__':
    sys.exit(main())
