from args import Args
from program import Program
from assertion import TapeAssertion
from errors import ProgramError, MultiProgramError, MultiParseError, OffEdgeOfTestTapeError, UnexpectedSuccessError, MultiUnexpectedSuccessError
from assertion_ctx import AssertionCtx, AssertionCtxIo
from colors import make_color, Color

import logging
from typing import cast, List

logger = logging.getLogger(__name__)

def _property_test_iteration(program: Program, start_code_index: int, seed: str, real_op_cap: int) -> bool:
    assertion = cast(TapeAssertion, program.code[start_code_index])
    assert isinstance(assertion, TapeAssertion)
    ctx = AssertionCtx(seed)
    program.tape = assertion.random_matching_tape(ctx)
    program.current = start_code_index - 1
    program.assertion_ctx = ctx
    program.io = AssertionCtxIo(ctx)
    try:
        program.iteration()
        while program.iteration():
            instr = program.code[program.current]
            if (instr.ends_assertion_block()):
                break
            if program.real_ops > real_op_cap:
                error = ProgramError('Took too long to complete')
                error.tape = program.tape
                error.span = instr.span()
                raise error
    except OffEdgeOfTestTapeError:
        pass # this is expected, the test is now over
    return ctx.random_used

def run_property_tests(args: Args, program: Program):
    io = program.io
    io.print('Running property tests…')
    errors: List[Exception] = []
    assertion_count = 0
    passes_iterations = 0
    some_assertions_always_fails = False
    for index, instr in enumerate(program.code):
        if isinstance(instr, TapeAssertion):
            logger.info('Testing ' + str(args.test_iterations) + ' scenarios starting at ' + str(instr.span()))
            an_iteration_succeeded = False
            real_op_cap = program.real_ops + args.test_endless_loop_threshold * args.test_iterations
            for i in range(args.test_iterations):
                try:
                    seed = str(assertion_count) + ',' + str(i)
                    seed_used = _property_test_iteration(program, index, seed, real_op_cap)
                    an_iteration_succeeded = True
                    passes_iterations += 1
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
                    if not seed_used:
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
    else:
        io.print(make_color(Color.GOOD,
            'All ' +
            str(passes_iterations) +
            ' test iterations from ' +
            str(assertion_count) +
            ' assertions passed'))
