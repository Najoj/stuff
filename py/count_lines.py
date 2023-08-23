#!/bin/python

import fileinput

lines = {}

for line in fileinput.input():
    line = line.strip()
    if line in lines.keys():
        lines[line] += 1
    else:
        lines[line] = 1

for key in lines.keys():
    print(f'{lines[key]} {key}')
