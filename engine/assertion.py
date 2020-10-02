from instruction import Instruction
from program import Program
from tape import Tape

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

    def matches(self, value: int) -> bool:
        raise NotImplementedError()

class VariableMatcher(Matcher):
    def __init__(self, name: str):
        self._name = name

    def __str__(self):
        return str(self._name)

    def matches(self, value: int) -> bool:
        return True # TODO

class LiteralMatcher(Matcher):
    def __init__(self, value: int):
        self._value = value

    def __str__(self):
        return str(self._value)

    def matches(self, value: int) -> bool:
        return self._value == value

class WildcardMatcher(Matcher):
    def __str__(self):
        return '*'

    def matches(self, value: int) -> bool:
        return True

class InverseMatcher(Matcher):
    def __init__(self, inner: Matcher):
        self._inner = inner

    def __str__(self):
        return '!' + str(inner)

    def matches(self, value: int) -> bool:
        return not self._inner.matches(value)

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
            if not cell.matches(actual[i]):
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
            if not matcher.matches(value):
                raise FailedError(self, None, 'output ' + str(value) + ' does not match ' + str(matcher))
        if len(program.unmatched_output) != 0:
            raise FailedError(self, None, 'some output not matched: ' + repr(program.unmatched_output))

    def loop_level_change(self) -> int:
        return 0
