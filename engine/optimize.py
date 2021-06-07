from instruction import Instruction
from op import Op
from program import Program
from span import Span

from typing import List, cast
from collections import defaultdict

class Block(Instruction):
    def __init__(self):
        self._code = ''
        self._values = defaultdict(lambda: 0)
        self._offset = 0
        self._required_left_room = 0
        self._required_right_room = 0
        self._emulated_ops = 0
        self._is_unrolled_loop = False
        self._span: Optional[Span] = None

    def __str__(self):
        return self._code + ' @ ' + str(self._span)

    def is_empty(self):
        return self._emulated_ops == 0

    def add_op(self, op: Instruction) -> bool:
        '''Returns true if the op was successfully added'''
        if not isinstance(op, Op):
            return False
        if op == '+':
            self._values[self._offset] += 1
        elif op == '-':
            self._values[self._offset] -= 1
        elif op == '>':
            self._offset += 1
            self._required_right_room = max(self._required_right_room, self._offset)
        elif op == '<':
            self._offset -= 1
            self._required_left_room = min(self._required_left_room, self._offset)
        elif op == '.':
            return False
        elif op == ',':
            return False
        elif op == '[':
            return False
        elif op == ']':
            return False
        else:
            assert False, 'Invalid operation ' + str(op)

        if self._values[self._offset] == 0:
            self._values.pop(self._offset)

        self._code += str(op)
        self._emulated_ops += 1
        if self._span is None:
            self._span = op.span()
        self._span = self._span.extend_to(op.span())

        return True

    def try_unroll_loop(self) -> bool:
        if self._is_unrolled_loop or self._offset or self._values[0] != -1:
            return False
        else:
            self._is_unrolled_loop = True
            self._emulated_ops += 1
            return True

    def run(self, program: Program):
        program.real_ops += 1 + len(self._values)
        program.tape.check_range_allowed(self._required_left_room, self._required_right_room)
        if self._is_unrolled_loop:
            multiplier = program.tape.get_value(0)
        else:
            multiplier = 1
        for key, val in self._values.items():
            program.tape.set_value(key, program.tape.get_value(key) + val * multiplier)
        program.tape.move_by(self._offset)
        emulated_ops = self._emulated_ops * multiplier
        if self._is_unrolled_loop:
            emulated_ops += 1
        program.emulated_ops += emulated_ops

    def loop_level_change(self) -> int:
        return 0

    def ends_assertion_block(self) -> bool:
        return False

    def span(self) -> Span:
        return self._span

def optimize(code: List[Instruction]) -> List[Instruction]:
    current = Block()
    result: List[Instruction] = []
    for instr in code:
        if not current.add_op(instr):
            if not current.is_empty():
                result.append(current)
                current = Block()
            result.append(instr)
    if not current.is_empty():
        result.append(current)
    i = 1
    while i < len(result) - 1:
        if (
            isinstance(result[i], Block) and
            result[i - 1] == '[' and
            result[i + 1] == ']'
        ):
            if cast(Block, result[i]).try_unroll_loop():
                result.pop(i + 1)
                result.pop(i - 1)
                i -= 2
        i += 1
    return result
