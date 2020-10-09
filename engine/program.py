from tape import Tape
from instruction import Instruction

from typing import List, Optional, Callable
from assertion_ctx import AssertionCtx

class Program:
    def __init__(self, tape: Tape, code: List[Instruction], output_fn: Callable[[str], None], input_fn: Callable[[], str]):
        self.tape = tape
        self.code = code
        self.current = 0
        self.stack: List[int] = []
        self.emulated_ops = 0
        self.real_ops = 0
        self.unmatched_output: List[int] = []
        self._output = output_fn
        self._input = input_fn
        self.assertion_ctx = AssertionCtx()

    def next_instruction(self) -> Optional[Instruction]:
        if self.current >= len(self.code):
            return None
        else:
            instruction = self.code[self.current]
            self.current += 1
            return instruction

    def send_output(self, value: int):
        self.unmatched_output.append(value)
        self._output(chr(value))

    def get_input(self) -> str:
        c = self._input()
        assert len(c) == 1, 'Invalid input: ' + repr(c)
        return c

    def iteration(self) -> bool:
        instruction = self.next_instruction()
        if instruction is None:
            return False
        instruction.run(self)
        return True
