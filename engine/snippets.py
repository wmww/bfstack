from instruction import Instruction
from errors import ParseError, MultiParseError, SingleParseError
from span import Span

from typing import TYPE_CHECKING, List, Optional

if TYPE_CHECKING:
    from span import Span
    from program import Program

class SnippetInstr(Instruction):
    def __init__(self, span: 'Span'):
        self._span = span

    def run(self, program: 'Program'):
        assert False, 'SnippetInstr should not have been run'

    def loop_level_change(self) -> int:
        return 0

    def ends_assertion_block(self) -> bool:
        return False

    def span(self) -> 'Span':
        return self._span

class SnippetStart(SnippetInstr):
    def __init__(self, name: str, span: 'Span'):
        super().__init__(span)
        self.name = name

class SnippetEnd(SnippetInstr):
    def __init__(self, span: 'Span'):
        super().__init__(span)

class _Snippet:
    def __init__(self, name: str):
        self._name = name
        self._spans: List[Span] = []
        self._code: Optional[str] = None

    def link(self, span: Span):
        code = span.ops()
        if self._code is None:
            self._code = code
        elif self._code != code:
            raise SingleParseError(self._name + '{}\'s code does not match first usage', span)
        self._spans.append(span)

class _Validator:
    def __init__(self):
        self._db: Dict[str, _Snippet] = {}

    def process(self, code: List[Instruction], error_accumulator: List[ParseError]):
        stack: List[SnippetStart] = []
        for instr in code:
            if isinstance(instr, SnippetStart):
                if not instr.name in self._db:
                    self._db[instr.name] = _Snippet(instr.name)
                stack.append(instr)
            elif isinstance(instr, SnippetEnd):
                if len(stack) == 0:
                    error_accumulator.append(SingleParseError('Unmatched }', instr.span()))
                else:
                    start = stack.pop()
                    try:
                        self._db[start.name].link(start.span().extend_to(instr.span()))
                    except SingleParseError as e:
                        error_accumulator.append(e)

def process(code: List[Instruction]) -> List[Instruction]:
    '''Raises a parse error if all snippets do not match, returns list with snippets removed'''
    errors: List[ParseError] = []
    validator = _Validator()
    validator.process(code, errors)
    if errors:
        raise MultiParseError(errors)
    return [instr for instr in code if not isinstance(instr, SnippetInstr)]
