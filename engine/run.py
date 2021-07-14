from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from io_interface import Io
from errors import ProgramError, ParseError, MultiParseError, UnexpectedSuccessError
from assertion_ctx import AssertionCtx, AssertionCtxIo
import use_file
import snippets
import optimize
from property_tests import run_property_tests

import time
import logging
from typing import cast, List

logger = logging.getLogger(__name__)

def run_normally(program: Program):
    logger.info('Program output:')
    while program.iteration():
        pass
    logger.info('Program done')

def run(args: Args, io: Io) -> None:
    program = None
    if args.source_path is None:
        raise RuntimeError('No source file')
    try:
        load_start_time = time.time()
        source_file = SourceFile(args.source_path, False)
        errors: List[ParseError] = []
        code = parse.source(source_file, args, errors)
        if args.snippets_enabled_anywhere():
            code = use_file.expand(code, args, errors)
            code = snippets.process(code, args, errors)
        if args.optimize:
            code = optimize.optimize(code)
        if errors:
            raise MultiParseError(errors)
        tape = Tape(0, [], True, False)
        program = Program(tape, code, io)
        program_start_time = time.time()
        logger.info('Took ' + str(round(program_start_time - load_start_time, 2)) + 's to load program')
        if args.prop_tests:
            run_property_tests(args, cast(Program, program))
        else:
            run_normally(cast(Program, program))
    except (ProgramError, ParseError) as e:
        if args.expect_fail:
            return
        else:
            raise
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
            if not args.prop_tests:
                logger.info('Tape: ' + str(tape))
    if args.expect_fail:
        error = UnexpectedSuccessError('Succeeded unexpectedly')
        if program:
            error.tape = program.tape
        raise error
