from instruction import Instruction
from program import Program
from tape import Tape
from assertion_ctx import AssertionCtx

from typing import Sequence, Optional

class FailedError(RuntimeError):
    def __init__(self, state, actual: Optional[Tape], message: Optional[str]):
        msg = '\nFailed: ' + str(state)
        if actual:
            msg += '\nActual:   ' + str(actual)
        if message:
            msg += '\n' + message
        super().__init__(msg)

class Matcher:
    def __str__(self):
        raise NotImplementedError()

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        raise NotImplementedError()

    def random_matching(self, ctx: AssertionCtx) -> int:
        raise NotImplementedError()

class VariableMatcher(Matcher):
    def __init__(self, name: str):
        self._name = name

    def __str__(self):
        return str(self._name)

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return True # TODO

    def random_matching(self, ctx: AssertionCtx) -> int:
        return ctx.random_byte() # TODO

class LiteralMatcher(Matcher):
    def __init__(self, text: str, value: int):
        self._text = text
        self._value = value

    def __str__(self):
        return self._text + ' (' + str(self._value) + ')'

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return self._value == value

    def random_matching(self, ctx: AssertionCtx) -> int:
        return self._value

class WildcardMatcher(Matcher):
    def __str__(self):
        return '*'

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return True

    def random_matching(self, ctx: AssertionCtx) -> int:
        return ctx.random_byte()

class InverseMatcher(Matcher):
    def __init__(self, inner: Matcher):
        self._inner = inner

    def __str__(self):
        return '!' + str(self._inner)

    def matches(self, ctx: AssertionCtx, value: int) -> bool:
        return not self._inner.matches(ctx, value)

    def random_matching(self, ctx: AssertionCtx) -> int:
        for i in range(256):
            v = ctx.random_byte()
            if not self._inner.matches(ctx, v):
                return v
        for i in range(256):
            if not self._inner.matches(ctx, i):
                return i
        raise RuntimeError('Literally nothing matches ' + str(self))

class TapeAssertion(Instruction):
    def __init__(self, cells: Sequence[Matcher], offset_of_current: int):
        self._cells = cells
        self._offset_of_current = offset_of_current

    def __str__(self):
        result = '= '
        for i, cell in enumerate(self._cells):
            if i:
                result += ' '
            if i == self._offset_of_current:
                result += '`'
            result += str(cell)
        return result

    def run(self, program: Program):
        program.real_ops += 1
        if program.tape.get_position() < self._offset_of_current:
            raise FailedError(self, None, 'too far left')
        actual = [program.tape.get_value(i - self._offset_of_current) for i in range(len(self._cells))]
        for i, cell in enumerate(self._cells):
            program.real_ops += 1
            if not cell.matches(program.assertion_ctx, actual[i]):
                actual_tape = Tape(self._offset_of_current, actual)
                raise FailedError(self, actual_tape, None)

    def loop_level_change(self) -> int:
        return 0

class OutputAssertion(Instruction):
    def __init__(self, matchers: Sequence[Matcher]):
        self._matchers = matchers

    def __str__(self):
        return ': ' + ' '.join(str(m) for m in self._matchers)

    def run(self, program: Program):
        program.real_ops += 1
        for matcher in self._matchers:
            if len(program.unmatched_output) == 0:
                raise FailedError(self, None, 'insufficient output')
            value = program.unmatched_output.pop(0)
            if not matcher.matches(program.assertion_ctx, value):
                raise FailedError(self, None, 'output ' + str(value) + ' does not match ' + str(matcher))
        if len(program.unmatched_output) != 0:
            raise FailedError(self, None, 'some output not matched: ' + repr(program.unmatched_output))

    def loop_level_change(self) -> int:
        return 0

class TestInput(Instruction):
    def __init__(self, matchers: Sequence[Matcher]):
        self._matchers = matchers

    def __str__(self):
        return '$ ' + ' '.join(str(m) for m in self._matchers)

    def run(self, program: Program):
        program.real_ops += 1
        if program.queued_input:
            raise RuntimeError('Test input given with ' + str(len(program.queued_input)) + ' unconsumed inputs')
        for m in self._matchers:
            program.real_ops += 1
            value = m.random_matching(program.assertion_ctx)
            program.queued_input.append(value)

    def loop_level_change(self) -> int:
        return 0
