#!/usr/bin/python3

from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from errors import ProgramError, ParseError

import sys
import time
import logging
from typing import List

logger = logging.getLogger(__name__)
input_buffer: List[str] = []
input_time: float = 0.0

def output_fn(c: str):
    print(c, end='')

def input_fn() -> str:
    global input_buffer
    global input_time
    start_time = time.time()
    while not input_buffer:
        input_buffer = list(input('input: ')) + ['\n']
    end_time = time.time()
    input_time += end_time - start_time
    return input_buffer.pop(0)

def main():
    args = Args()
    args.parse(sys.argv[1:]) # strip off the first argument (program name)
    program = None
    if args.show_info:
        logging.basicConfig(level=logging.INFO)
    try:
        load_start_time = time.time()
        source_file = SourceFile(args)
        code = parse.source(source_file, args)
        tape = Tape(0, [])
        program = Program(tape, code, output_fn, input_fn)
        program_start_time = time.time()
        logger.info('Took ' + str(round(program_start_time - load_start_time, 2)) + 's to load program')
        logger.info('Program output:')
        while program.iteration():
            pass
        program.finalize()
        print()
        logger.info('Program done')
    except ParseError as e:
        logger.error('Syntax error: ' + str(e))
        exit(1) # will still run the finally: block
    except ProgramError as e:
        print()
        logger.error('Program failed: ' + str(e))
        exit(1) # will still run the finally: block
    finally:
        if program:
            program_end_time = time.time()
            logger.info(
                'Took ' + str(round(program_end_time - program_start_time - input_time, 2)) + 's to run the program' +
                ' (plus ' + str(round(input_time, 2)) + 's waiting for input)')
            logger.info('Ran ' + str(program.emulated_ops) + ' virtual brainfuck operations')
            logger.info('Ran ' + str(program.real_ops) + ' real constant time operations')
            logger.info('Tape: ' + str(tape))

if __name__ == '__main__':
    main();
