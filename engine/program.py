from tape import Tape
from instruction import Instruction
from errors import ProgramError
from io_interface import Io

from typing import List, Optional, Callable
from assertion_ctx import AssertionCtx

class Program:
    def __init__(self, tape: Tape, code: List[Instruction], io: Io):
        self.tape = tape
        self.code = code
        self.current = 0
        self.stack: List[int] = []
        self.emulated_ops = 0
        self.real_ops = 0
        self.io = io
        self.assertion_ctx = AssertionCtx()

    def next_instruction(self) -> Optional[Instruction]:
        if self.current >= len(self.code):
            return None
        else:
            instruction = self.code[self.current]
            self.current += 1
            return instruction

    def iteration(self) -> bool:
        instruction = self.next_instruction()
        if instruction is None:
            return False
        try:
            instruction.run(self)
        except ProgramError as e:
            if e.span() is None:
                e.set_span(instruction.span())
            raise
        return True

    def finalize(self):
        assert len(self.stack) == 0, 'Program exited with unmatched \'[\' (should have been caught in parsing)'
