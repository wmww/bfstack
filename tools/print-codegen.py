#!/usr/bin/env python3
import sys
s = sys.argv[1]
print('[ print "' + s + '" ]')
i = 0
for c in s:
    c = ord(c)
    if c < i :
        line = '-' * (i - c)
    else:
        line = '+' * (c - i)
    line += '.'
    while len(line) > 10:
        print(line[:10])
        line = line[10:]
    print(line)
    i = c
print('[-]')
