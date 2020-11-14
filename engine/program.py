from tape import Tape
from instruction import Instruction
from errors import ProgramError
from io_interface  import Io
from assertion_ctx import AssertionCtx

from typing import List, Optional, Dict

class Program:
    def __init__(self, tape: Tape, code: List[Instruction], io: Io):
        self.tape = tape
        self.code = tuple(code)
        self.current = -1
        self.emulated_ops = 0
        self.real_ops = 0
        self.io = io
        self.assertion_ctx = AssertionCtx(0) # Use 0 seed by default
        self._cached_loop_pairs: Dict[int, int] = {}

    def next_instruction(self) -> Optional[Instruction]:
        if self.current >= len(self.code) - 1:
            return None
        else:
            self.current += 1
            return self.code[self.current]

    def iteration(self) -> bool:
        instruction = self.next_instruction()
        if instruction is None:
            return False
        try:
            instruction.run(self)
        except ProgramError as e:
            if not e.tape:
                e.tape = self.tape
            if not e.span:
                e.span = instruction.span()
            raise
        return True

    def _find_matching_loop(self, index: int) -> int:
        level = self.code[index].loop_level_change()
        assert level != 0, 'find_matching_loop() on non-loop instruction ' + str(self.code[index])
        if level > 0:
            walk = 1
        elif level < 0:
            walk = -1
        while level != 0:
            index += walk
            assert index >= 0 and index < len(self.code), 'Unmatched brace (should have been caught in parsing)'
            level += self.code[index].loop_level_change()
        return index

    def matching_loop(self, index: int) -> int:
        if index not in self._cached_loop_pairs:
            other = self._find_matching_loop(index)
            self._cached_loop_pairs[index] = other
            self._cached_loop_pairs[other] = index
        return self._cached_loop_pairs[index]
