#!/usr/bin/python3

from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse

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
    arguments = Args(sys.argv)
    source_file = SourceFile(arguments.source_path())
    code = parse.source(source_file)
    program = Program(Tape(0, []), code, output_fn, input_fn)
    while program.iteration():
        pass

if __name__ == '__main__':
    #logging.basicConfig(level=logging.INFO)
    main();
