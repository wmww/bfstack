from instruction import Instruction
from program import Program

from typing import List, Optional

class FailedError(RuntimeError):
    def __init__(self, state, actual: Optional[List[int]], message: Optional[str]):
        msg = '\nFailed: ' + str(state)
        if actual:
            msg += '\nActual:   ' + ' '.join(str(i) for i in actual)
        if message:
            msg += '\n' + message
        super().__init__(msg)

class AssertionCell:
    def __init__(self, is_current: bool, value):
        assert isinstance(value, int) or isinstance(value, str) or value is None, str(value)
        self.is_current = is_current
        self._value = value

    def __str__(self):
        return ('`' if self.is_current else '') + str(self._value)

    def matches(self, value: int) -> bool:
        if isinstance(self._value, int):
            return self._value == value
        elif isinstance(self._value, str):
            return True
        else:
            return True

class Assertion(Instruction):
    def __init__(self, cells: List[AssertionCell]):
        assert isinstance(cells, list)
        is_current_count = 0
        for i, cell in enumerate(cells):
            if cell.is_current:
                self._current_offset = i
                is_current_count += 1
        if is_current_count != 1:
            raise RuntimeError('Assertion should have exactly one current cell')
        self._cells = cells

    def __str__(self):
        return '= ' + ' '.join(str(cell) for cell in self._cells)

    def run(self, program: Program):
        if program.tape.get_position() < self._current_offset:
            raise FailedError(self, None, 'Too far left')
        actual = [program.tape.get_value(i - self._current_offset) for i in range(len(self._cells))]
        for i, cell in enumerate(self._cells):
            if not cell.matches(actual[i]):
                raise FailedError(self, actual, None)

    def loop_level_change(self) -> int:
        return 0
