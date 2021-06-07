from instruction import Instruction
from errors import ParseError, MultiParseError, SingleParseError
from span import Span

from typing import TYPE_CHECKING, List, Optional, Dict

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
    def __init__(self, name_components: List[str], span: 'Span'):
        '''name_components ends with the snippet name, and does not contain any ':'s'''
        super().__init__(span)
        self._name_components = name_components
        self._can_be_first_instance = len(name_components) == 1

    def clone_with_prefix(self, prefix: str) -> 'SnippetStart':
        result = SnippetStart([prefix] + self._name_components, self._span)
        result._can_be_first_instance = self._can_be_first_instance
        return result

    def can_be_first_instance(self) -> bool:
        return self._can_be_first_instance

    def name(self) -> str:
        return '::'.join(self._name_components)

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

def process(code: List[Instruction], error_accumulator: List[ParseError]) -> list[Instruction]:
    '''Adds parse errors to the accumulator for unmatching snippets, returns list with snippets removed'''
    db: Dict[str, _Snippet] = {}
    stack: List[SnippetStart] = []
    for instr in code:
        if isinstance(instr, SnippetStart):
            start_name = instr.name()
            if not start_name in db:
                if instr.can_be_first_instance():
                    db[start_name] = _Snippet(start_name)
                else:
                    error_accumulator.append(SingleParseError(
                        'Unknown snippet "' + start_name + '", known snippets: ' + str(list(db.keys())),
                        instr.span(),
                    ))
            stack.append(instr)
        elif isinstance(instr, SnippetEnd):
            if len(stack) == 0:
                error_accumulator.append(SingleParseError('Unmatched "}"', instr.span()))
            else:
                start = stack.pop()
                try:
                    db[start.name()].link(start.span().extend_to(instr.span()))
                except SingleParseError as e:
                    error_accumulator.append(e)
                except KeyError:
                    pass # Can happen when there's an error creating the span
    for snippet in reversed(stack):
        error_accumulator.append(SingleParseError('Unmatched "' + snippet.name() + '{"', snippet.span()))
    return [instr for instr in code if not isinstance(instr, SnippetInstr)]
