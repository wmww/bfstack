#!/usr/bin/python3

from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from errors import ProgramError, ParseError
from io_interface import Io

import sys
import time
import logging
from typing import List

logger = logging.getLogger(__name__)

class UserIo(Io):
    def __init__(self):
        self.input_time: float = 0.0
        self.input_buffer: List[str] = []

    def push_output(self, value: int):
        print(chr(value), end='')

    def pull_input(self) -> int:
        if not self.input_buffer:
            start_time = time.time()
            self.input_buffer = list(input('input: ')) + ['\n']
            end_time = time.time()
            self.input_time += end_time - start_time
        return ord(self.input_buffer.pop(0))

    def queue_input(self, values: List[int]):
        pass

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
        io = UserIo()
        program = Program(tape, code, io)
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
                'Took ' + str(round(program_end_time - program_start_time - io.input_time, 2)) + 's to run the program' +
                ' (plus ' + str(round(io.input_time, 2)) + 's waiting for input)')
            logger.info('Ran ' + str(program.emulated_ops) + ' virtual brainfuck operations')
            logger.info('Ran ' + str(program.real_ops) + ' real constant time operations')
            logger.info('Tape: ' + str(tape))

if __name__ == '__main__':
    main();
