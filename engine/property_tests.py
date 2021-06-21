from args import Args
from program import Program
from assertion import TapeAssertion
from errors import ProgramError, MultiProgramError, MultiParseError, OffEdgeOfTestTapeError, UnexpectedSuccessError, MultiUnexpectedSuccessError
from assertion_ctx import AssertionCtx, AssertionCtxIo

import logging
from typing import cast, List

logger = logging.getLogger(__name__)

def _property_test_iteration(program: Program, start_code_index: int, seed: str):
    assertion = cast(TapeAssertion, program.code[start_code_index])
    assert isinstance(assertion, TapeAssertion)
    ctx = AssertionCtx(seed)
    program.tape = assertion.random_matching_tape(ctx)
    program.current = start_code_index - 1
    program.assertion_ctx = ctx
    program.io = AssertionCtxIo(ctx)
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
                    _property_test_iteration(program, index, seed)
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
