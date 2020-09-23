from tape import Tape
from instruction import Instruction

from typing import List, Optional, Callable

class Program:
    def __init__(self, tape: Tape, code: List[Instruction], output_fn: Callable[[str], None], input_fn: Callable[[], str]):
        self.tape = tape
        self.code = code
        self.current = 0
        self.stack: List[int] = []
        self._output = output_fn
        self._input = input_fn

    def next_instruction(self) -> Optional[Instruction]:
        if self.current >= len(self.code):
            return None
        else:
            instruction = self.code[self.current]
            self.current += 1
            return instruction

    def send_output(self, c: str):
        assert len(c) == 1, 'Invalid output: ' + repr(c)
        self._output(c)

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
