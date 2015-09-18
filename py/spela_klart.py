#!/usr/bin/env python3.2
#-*- coding:utf-8 -*-

# MPD
from musicpd  import MPDClient

import time
import sys

def printTime(t):
    # Time in minutes and rest
    tm = int(t/60)
    ts = int(t%60)
    
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
    try:
        client = MPDClient()
        client.connect("localhost", 6600)
        currentTrack = client.status()['songid']
        
        
        while currentTrack == client.status()['songid']:
            t = int(float(client.currentsong()['time']) - float(client.status()['elapsed']))
            print (printTime(t), end='\r')
            sys.stdout.flush()
            time.sleep(0.25)
            
            
        client.close()
        client.disconnect()
    except:
        return 1


    
    print ('00:00')
    
    return 0

if __name__ == '__main__':
    sys.exit(main())
