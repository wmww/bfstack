from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from span import Span
    from program import Program

class Instruction:
    def run(self, program: 'Program'):
        raise NotImplementedError()

    def loop_level_change(self) -> int:
        raise NotImplementedError()

    def ends_assertion_block(self) -> bool:
        raise NotImplementedError()

    def span(self) -> 'Span':
        raise NotImplementedError()
