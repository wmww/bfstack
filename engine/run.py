from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from io_interface import Io
from assertion import TapeAssertion
from errors import ProgramError, MultiProgramError, OffEdgeOfTestTapeError
from assertion_ctx import AssertionCtx

import time
import logging
from typing import cast

logger = logging.getLogger(__name__)

def property_test_iteration(program: Program, start_code_index: int, assertion: TapeAssertion, seed: str):
    ctx = AssertionCtx(seed)
    try:
        program.tape = assertion.random_matching_tape(ctx)
    except OffEdgeOfTestTapeError as e:
        # This will be ignored by calling function if we don't handle it
        assert False, 'OffEdgeOfTestTapeError raised in test tape setup'
    except ProgramError as e:
        e.set_context(assertion.span(), None)
        raise
    program.current = start_code_index - 1
    program.io.reset()
    program.assertion_ctx = ctx
    while program.iteration():
        if (program.current != start_code_index and
            isinstance(program.code[program.current], TapeAssertion)):
            break

def run_property_tests(args: Args, program: Program):
    logger.info('Testing program')
    errors = []
    assertion_count = 0
    for index, instr in enumerate(program.code):
        if isinstance(instr, TapeAssertion):
            logger.info('Testing ' + str(args.test_iterations) + ' scenarios starting at ' + str(instr.span()))
            try:
                for i in range(args.test_iterations):
                    try:
                        seed = str(assertion_count) + ',' + str(i)
                        property_test_iteration(program, index, cast(TapeAssertion, instr), seed)
                    except OffEdgeOfTestTapeError as e:
                        pass # this is expected, the test is now over
            except ProgramError as e:
                errors.append(e)
            assertion_count += 1
    if errors:
        logger.info('Tests failed')
        raise MultiProgramError(errors)
    else:
        logger.info('Tests complete')

def run_normally(program):
    logger.info('Program output:')
    while program.iteration():
        pass
    logger.info('Program done')

def run(args: Args, io: Io) -> Program:
    program = None
    try:
        load_start_time = time.time()
        source_file = SourceFile(args)
        code = parse.source(source_file, args)
        tape = Tape(0, [], True, False)
        program = Program(tape, code, io)
        program_start_time = time.time()
        logger.info('Took ' + str(round(program_start_time - load_start_time, 2)) + 's to load program')
        if args.prop_tests:
            run_property_tests(args, program)
        else:
            run_normally(program)
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
    return program
