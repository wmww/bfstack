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

    def run(self, program: Program):
        for key, val in self._values.items():
            program.tape.set_value(key, program.tape.get_value(key) + val)
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
