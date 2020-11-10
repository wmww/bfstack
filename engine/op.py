from span import Span
from instruction import Instruction
from program import Program

op_set = set(['+', '-', '<', '>', '[', ']', '.', ','])

class Op(Instruction):
    def __init__(self, op: str, span: Span):
        assert op in op_set, 'Invalid operation ' + op
        self._op = op
        self._span = span

    def __str__(self):
        return self._op

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
            program.io.push_output(program.tape.get_value(0))
        elif op == ',':
            program.tape.set_value(0, program.io.pull_input())
        elif op == '[':
            if program.tape.get_value(0) == 0:
                program.current = program.find_matching_loop(program.current)
        elif op == ']':
            if program.tape.get_value(0) != 0:
                program.current = program.find_matching_loop(program.current)
        else:
            assert False, 'Invalid operation ' + repr(op)

    def loop_level_change(self) -> int:
        if self._op == '[':
            return 1
        elif self._op == ']':
            return -1
        else:
            return 0

    def span(self) -> Span:
        return self._span
