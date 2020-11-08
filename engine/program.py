from tape import Tape
from instruction import Instruction
from errors import ProgramError

from typing import List, Optional, Callable
from assertion_ctx import AssertionCtx

class Program:
    def __init__(self, tape: Tape, code: List[Instruction], output_fn: Callable[[str], None], input_fn: Optional[Callable[[], str]]):
        self.tape = tape
        self.code = code
        self.current = 0
        self.stack: List[int] = []
        self.emulated_ops = 0
        self.real_ops = 0
        self.queued_input: List[int] = []
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
        self._output(chr(value))

    def get_input(self) -> str:
        if self._input:
            c = self._input()
        elif self.queued_input:
            c = chr(self.queued_input.pop(0))
        else:
            raise ProgramError('No queueud input')
        assert len(c) == 1, 'Invalid input: ' + repr(c)
        return c

    def iteration(self) -> bool:
        instruction = self.next_instruction()
        if instruction is None:
            return False
        instruction.run(self)
        return True

    def finalize(self):
        assert len(self.stack) == 0, 'Program exited with unmatched \'[\' (should have been caught in parsing)'
        if self.queued_input and not self._input:
            raise ProgramError('Program finalized with ' + str(len(self.queued_input)) + ' unconsumed test inputs')
