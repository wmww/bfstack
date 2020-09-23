import assertion

from typing import List, Optional, Callable

ops = set(['+', '-', '<', '>', '[', ']', '.', ','])

class TooFarLeftError(RuntimeError):
    def __init__(self):
        super().__init__('Too far left')

class Tape:
    def __init__(self, position: int, data: List[int]):
        assert position >= 0
        self._position = position
        self._data = data

    def __str__(self):
        result = []
        for i, cell in enumerate(self._data):
            if i == self._position:
                result.append('`' + str(cell))
            else:
                result.append(str(cell))
        return ' '.join(result)

    def get_position(self) -> int:
        return self._position

    def get_value_relative(self, offset: int) -> int:
        i = self._position + offset
        if i < 0:
            raise TooFarLeftError()
        elif i >= len(self._data):
            return 0
        else:
            return self._data[i]

    def set_value_relative(self, offset: int, value: int):
        value = value % 256
        i = self._position + offset
        if i < 0:
            raise TooFarLeftError()
        while i >= len(self._data):
            self._data.append(0)
        self._data[i] = value

    def increment_by(self, value: int):
        self.set_value_relative(0, self.get_value_relative(0) + value)

    def move_by(self, delta: int):
        if -delta > self._position:
            raise TooFarLeftError()
        self._position += delta

class Instruction:
    def __init__(self, line: int, col: int, op: str):
        assert op in ops, 'Invalid operation ' + op
        self._line = line
        self._col = col
        self.op = op

    def __str__(self):
        return self.op + ' @ ' + str(self._line) + ':' + str(self._col)

class Code:
    def __init__(self, code: List[Instruction]):
        self.code = code

    def __str__(self):
        return ''.join(op.op for op in self.code)

class Engine:
    def __init__(self, tape: Tape, sections: List, output_fn: Callable[[str], None], input_fn: Callable[[], str]):
        self._tape = tape
        self._sections = sections
        self._current = [0, 0]
        self._loop_stack: List[List[int]] = []
        self._output = output_fn
        self._input = input_fn

    def _next(self):
        if self._current[0] >= len(self._sections):
            return None
        section = self._sections[self._current[0]]
        if isinstance(section, assertion.State):
            self._current[0] += 1
            self._current[1] = 0
            return section
        elif isinstance(section, Code):
            instruction = section.code[self._current[1]]
            self._current[1] += 1
            if self._current[1] >= len(section.code):
                self._current[0] += 1
                self._current[1] = 0
            return instruction
        else:
            assert False, 'Invalid section ' + repr(section)

    def _run_op(self, op: str):
        if op == '+':
            self._tape.increment_by(1)
        elif op == '-':
            self._tape.increment_by(-1)
        elif op == '>':
            self._tape.move_by(1)
        elif op == '<':
            self._tape.move_by(-1)
        elif op == '.':
            self._output(chr(self._tape.get_value_relative(0)))
        elif op == ',':
            self._tape.set_value_relative(0, ord(self._input()))
        elif op == '[':
            if self._tape.get_value_relative(0):
                self._loop_stack.append(list(self._current))
            else:
                level = 1
                while level > 0:
                    unit = self._next()
                    if unit is None:
                        raise RuntimeError('Unmatched \'[\'')
                    elif isinstance(unit, Instruction):
                        if unit.op == ']':
                            level -= 1
                        elif unit.op == '[':
                            level += 1
        elif op == ']':
            if not self._loop_stack:
                raise RuntimeError('Unmatched \']\'')
            if self._tape.get_value_relative(0):
                self._current = list(self._loop_stack[-1])
            else:
                self._loop_stack.pop()
        else:
            assert False, 'Invalid operation ' + repr(op)

    def iteration(self) -> bool:
        unit = self._next()
        if unit is None:
            return False
        elif isinstance(unit, assertion.State):
            unit.match(self._tape)
        elif isinstance(unit, Instruction):
            try:
                self._run_op(unit.op)
            except RuntimeError as e:
                raise RuntimeError(str(unit) + ': ' + str(e))
        else:
            assert False, 'Invalid section ' + repr(section)
        return True
