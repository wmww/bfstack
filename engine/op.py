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

    def __eq__(self, other):
        if isinstance(other, Op):
            return self._op == other._op
        elif isinstance(other, str):
            return self._op == other
        else:
            return False

    def run(self, program: Program):
        op = self._op
        program.emulated_ops += 1
        program.real_ops += 1
        if op == '+':
            program.tape.set_value(0, program.tape.get_value(0) + 1)
        elif op == '-':
            program.tape.set_value(0, program.tape.get_value(0) - 1)
        elif op == '>':
            program.tape.move_by(1)
        elif op == '<':
            program.tape.move_by(-1)
        elif op == '.':
            program.send_output(program.tape.get_value(0))
        elif op == ',':
            program.tape.set_value(0, ord(program.get_input()))
        elif op == '[':
            if program.tape.get_value(0):
                program.stack.append(program.current)
            else:
                level = 1
                while level > 0:
                    instr = program.next_instruction()
                    assert instr is not None, 'Unmatched \'[\' (should have been caught in parsing)'
                    level += instr.loop_level_change()
                assert level == 0, 'Failed to find exact loop match (should have been caught in parsing)'
        elif op == ']':
            assert program.stack, 'Unmatched \']\' (should have been caught in parsing)'
            if program.tape.get_value(0):
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
