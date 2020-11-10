from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from io_interface import Io

import time
import logging

logger = logging.getLogger(__name__)

def run(args: Args, io: Io):
    program = None
    try:
        load_start_time = time.time()
        source_file = SourceFile(args)
        code = parse.source(source_file, args)
        tape = Tape(0, [])
        program = Program(tape, code, io)
        program_start_time = time.time()
        logger.info('Took ' + str(round(program_start_time - load_start_time, 2)) + 's to load program')
        logger.info('Program output:')
        while program.iteration():
            pass
        program.finalize()
        logger.info('Program done')
    finally:
        if program:
            program_end_time = time.time()
            input_time = io.time_waiting_for_input()
            program_time = program_end_time - program_start_time - input_time
            logger.info(
                'Took ' + str(round(program_time, 2)) + 's to run the program' +
                ' (plus ' + str(round(input_time, 2)) + 's waiting for input)')
            logger.info('Ran ' + str(program.emulated_ops) + ' virtual brainfuck operations')
            logger.info('Ran ' + str(program.real_ops) + ' real constant time operations')
            logger.info('Tape: ' + str(tape))
