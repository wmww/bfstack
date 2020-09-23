from instruction import Instruction
from program import Program

op_set = set(['+', '-', '<', '>', '[', ']', '.', ','])

class Op(Instruction):
    def __init__(self, line: int, col: int, op: str):
        assert op in op_set, 'Invalid operation ' + op
        self._line = line
        self._col = col
        self._op = op

    def __str__(self):
        return self.op + ' @ ' + str(self._line) + ':' + str(self._col)

    def run(self, program: Program):
        op = self._op
        if op == '+':
            program.tape.increment_by(1)
        elif op == '-':
            program.tape.increment_by(-1)
        elif op == '>':
            program.tape.move_by(1)
        elif op == '<':
            program.tape.move_by(-1)
        elif op == '.':
            program.send_output(chr(program.tape.get_value_relative(0)))
        elif op == ',':
            program.tape.set_value_relative(0, ord(program.get_input()))
        elif op == '[':
            if program.tape.get_value_relative(0):
                program.stack.append(program.current)
            else:
                level = 1
                while level > 0:
                    instr = program.next_instruction()
                    if instr is None:
                        raise RuntimeError('Unmatched \'[\'')
                    level += instr.loop_level_change()
                if level != 0:
                    raise RuntimeError('Failed to find exact loop match')
        elif op == ']':
            if not program.stack:
                raise RuntimeError('Unmatched \']\'')
            if program.tape.get_value_relative(0):
                program.current = program.stack[-1]
            else:
                program.stack.pop()
        else:
            assert False, 'Invalid operation ' + repr(op)

    def loop_level_change(self) -> int:
        if self._op == '[':
            return 1
        elif self._op == ']':
            return -1
        else:
            return 0
