from instruction import Instruction
from op import Op
from program import Program

from typing import List
from collections import defaultdict

class Block(Instruction):
    def __init__(self):
        self._code = ''
        self._values = defaultdict(lambda: 0)
        self._offset = 0
        self._is_unrolled_loop = False

    def __str__(self):
        return self._code

    def is_empty(self):
        return not self._values and self._offset == 0

    def add_op(self, op: Instruction) -> bool:
        if not isinstance(op, Op):
            return False
        if op == '+':
            self._values[self._offset] += 1
        elif op == '-':
            self._values[self._offset] -= 1
        elif op == '>':
            self._offset += 1
        elif op == '<':
            self._offset -= 1
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

        return True

    def try_unroll_loop(self) -> bool:
        if self._is_unrolled_loop or self._offset or self._values[0] != -1:
            return False
        else:
            self._is_unrolled_loop = True
            return True

    def run(self, program: Program):
        if self._is_unrolled_loop:
            multiplier = program.tape.get_value(0)
        else:
            multiplier = 1
        for key, val in self._values.items():
            program.tape.set_value(key, program.tape.get_value(key) + val * multiplier)
        program.tape.move_by(self._offset)

    def loop_level_change(self) -> int:
        return 0

def optimize(code: List[Instruction]):
    block = Block()
    i = 0
    while i < len(code):
        if block.add_op(code[i]):
            code.pop(i)
        elif block.is_empty():
            i += 1
        else:
            code.insert(i, block)
            block = Block()
            i += 2
    code.append(block)
    i = 1
    while i < len(code) - 1:
        if (isinstance(code[i], Block) and code[i - 1] == '[' and code[i + 1] == ']'):
            if code[i].try_unroll_loop():
                code.pop(i + 1)
                code.pop(i - 1)
        i += 1
