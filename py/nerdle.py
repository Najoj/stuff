NUMBERS = [str(x) for x in [0,1,2,3,4,5,6,7,8,9]]
OPERATORS = ['+', '-', '*', '/']

positions = [None] * 8

def number(include=None, exclude=None):
    yield from NUMBERS

for