from span import Span

class Instruction:
    def run(self, program):
        raise NotImplementedError()

    def loop_level_change(self) -> int:
        raise NotImplementedError()

    def span(self) -> Span:
        raise NotImplementedError()
