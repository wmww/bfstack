from args import Args
from source_file import SourceFile
from program import Program
from tape import Tape
import parse
from io_interface import Io
from assertion import TapeAssertion
from errors import ProgramError, ParseError, MultiProgramError, MultiParseError, OffEdgeOfTestTapeError, UnexpectedSuccessError, MultiUnexpectedSuccessError
from assertion_ctx import AssertionCtx
import optimize
import snippets

import time
import logging
from typing import cast, Callable, List

logger = logging.getLogger(__name__)

def property_test_iteration(program: Program, start_code_index: int, seed: str):
    assertion = cast(TapeAssertion, program.code[start_code_index])
    assert isinstance(assertion, TapeAssertion)
    ctx = AssertionCtx(seed)
    program.tape = assertion.random_matching_tape(ctx)
    program.current = start_code_index - 1
    program.io.reset()
    program.assertion_ctx = ctx
    try:
        max_iters = 10000
        current_iter = 0
        program.iteration()
        while program.iteration():
            instr = program.code[program.current]
            if (instr.ends_assertion_block()):
                break
            current_iter += 1
            if current_iter > max_iters:
                error = ProgramError('Took too long to complete')
                error.tape = program.tape
                error.span = instr.span()
                raise error
    except OffEdgeOfTestTapeError:
        pass # this is expected, the test is now over

def run_property_tests(args: Args, program: Program):
    logger.info('Testing program')
    errors: List[Exception] = []
    assertion_count = 0
    some_assertions_always_fails = False
    for index, instr in enumerate(program.code):
        if isinstance(instr, TapeAssertion):
            logger.info('Testing ' + str(args.test_iterations) + ' scenarios starting at ' + str(instr.span()))
            an_iteration_succeeded = False
            for i in range(args.test_iterations):
                try:
                    seed = str(assertion_count) + ',' + str(i)
                    property_test_iteration(program, index, seed)
                    program.io.reset()
                    an_iteration_succeeded = True
                    if args.expect_fail:
                        assertion = cast(TapeAssertion, program.code[index])
                        start_tape = assertion.random_matching_tape(AssertionCtx(seed))
                        msg = ''
                        msg += 'Start tape: ' + str(start_tape) + '\n'
                        msg += 'Final tape: ' + str(program.tape) + '\n'
                        msg += 'No error raised'
                        e = UnexpectedSuccessError(msg)
                        e.span = assertion.span()
                        errors.append(e)
                        break
                except ProgramError as e:
                    if not args.expect_fail:
                        errors.append(e)
                        break
            if not an_iteration_succeeded:
                some_assertions_always_fails = True
            assertion_count += 1
    if args.expect_fail:
        if some_assertions_always_fails:
            raise ProgramError('This expected error should be caught')
        elif errors:
            raise MultiUnexpectedSuccessError(errors)
        else:
            raise UnexpectedSuccessError('Property tests succeeded unexpectedly')
    elif errors:
        raise MultiProgramError(errors)

def run_normally(program: Program):
    logger.info('Program output:')
    while program.iteration():
        pass
    logger.info('Program done')

def run(args: Args, io: Io) -> None:
    program = None
    try:
        load_start_time = time.time()
        source_file = SourceFile(args.source_path)
        errors: List[ParseError] = []
        code = parse.source(source_file, args, errors)
        if args.snippets:
            code = snippets.process(code, errors)
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
        io.reset()
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
