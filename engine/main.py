#!/usr/bin/python3

import args
import parse
import engine

import sys
import logging
from typing import List

logger = logging.getLogger(__name__)
input_buffer: List[str] = []

def output_fn(c: str):
    print(c, end='')

def input_fn() -> str:
    global input_buffer
    while not input_buffer:
        input_buffer = list(input('input: ')) + ['\n']
    return input_buffer.pop(0)

def main():
    arguments = args.Args(sys.argv)
    source_file = arguments.load_source_file()
    sections = parse.source_file(source_file)
    eng = engine.Engine(engine.Tape(0, []), sections, output_fn, input_fn)
    while eng.iteration():
        pass

if __name__ == '__main__':
    #logging.basicConfig(level=logging.INFO)
    main();
