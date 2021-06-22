from instruction import Instruction
from errors import ParseError, MultiParseError, SingleParseError
from span import Span
from args import Args
from source_file import SourceFile

from typing import TYPE_CHECKING, List, Optional, Dict, Tuple

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
    UNNAMED_SNIPPET_NAME = '[unnamed snippet]'

    def __init__(self, prefix: Optional[str], name: str, span: 'Span'):
        super().__init__(span)
        self._prefix = prefix
        self._name = name

    def prefix(self) -> Optional[str]:
        return self._prefix

    def name(self) -> str:
        return self._name

    def prefix_name(self) -> str:
        result = ''
        if self._prefix is not None:
            result += self._prefix + '/'
        result += self._name
        return result

class SnippetEnd(SnippetInstr):
    def __init__(self, span: 'Span'):
        super().__init__(span)

class _Snippet:
    def __init__(self, start: SnippetStart, end: SnippetEnd):
        self.start = start
        self.end = end

    def can_be_declaration(self) -> bool:
        # Snippets with an explicit prefix can not be declarations
        return self.start.prefix() is None

    def key(self) -> Tuple[SourceFile, str]:
        start_source = self.start.span().source_file()
        prefix = self.start.prefix()
        if prefix is None:
            return start_source, self.start.name()
        else:
            used_source = start_source.get_used_file(prefix)
            if used_source is None:
                raise SingleParseError(
                    prefix + ' does not refer to an explicitly used file ',
                    self.start.span()
                )
            return used_source, self.start.name()

    def span(self) -> Span:
        return self.start.span().extend_to(self.end.span())

    def ops(self) -> str:
        '''returns the contained brainfuck operations represented in a string'''
        return self.span().ops()

    def check_against(self, other: '_Snippet', error_accumulator: List[ParseError]):
        assert self.key() == other.key()
        name = self.start.name()
        if name != SnippetStart.UNNAMED_SNIPPET_NAME and self.ops() != other.ops():
            error_accumulator.append(SingleParseError(
                name + '{}\'s code does not match initial usage at ' + str(other.span()),
                self.span()
            ))

class _Ctx:
    def __init__(
        self,
        snippets: List[_Snippet],
        args: Args,
        error_accumulator: List[ParseError]
    ):
        self.snippets = snippets
        self.args = args
        self.errors = error_accumulator
        # maps declaration source files and names to snippets
        self.declarations: Dict[Tuple[SourceFile, str], _Snippet] = dict()

    def process_declarations(self) -> None:
        for snippet in self.snippets:
            try:
                if snippet.can_be_declaration():
                    key = snippet.key()
                    if key not in self.declarations:
                        self.declarations[key] = snippet
            except ParseError as e:
                self.errors.append(e)

    def process_usages(self) -> None:
        for snippet in self.snippets:
            if self.args.snippets_enabled_for(snippet.start.span()):
                try:
                    declaration = self.declarations.get(snippet.key())
                    if declaration is None:
                        self.errors.append(SingleParseError(
                            'Unknown snippet ' + snippet.start.prefix_name() + '{}',
                            snippet.start.span(),
                        ))
                    else:
                        snippet.check_against(declaration, self.errors)
                except ParseError as e:
                    self.errors.append(e)

def _parse_snippets(
    code: List[Instruction],
    error_accumulator: List[ParseError]
) -> List[_Snippet]:
    stack = []
    result = []
    for instr in code:
        if isinstance(instr, SnippetStart):
            stack.append(instr)
        elif isinstance(instr, SnippetEnd):
            if len(stack) == 0:
                error_accumulator.append(SingleParseError('Unmatched "}"', instr.span()))
            else:
                start = stack.pop()
                result.append(_Snippet(start, instr))
    for snippet in stack:
        error_accumulator.append(SingleParseError('Unmatched "' + snippet.name() + '{"', snippet.span()))
    return result

def _filter_snippet_instructions(code: List[Instruction]) -> List[Instruction]:
    return [instr for instr in code if not isinstance(instr, SnippetInstr)]

def process(code: List[Instruction], args: Args, error_accumulator: List[ParseError]) -> list[Instruction]:
    '''Adds parse errors to the accumulator for unmatching snippets, returns list with snippets removed'''
    snippets = _parse_snippets(code, error_accumulator)
    ctx = _Ctx(snippets, args, error_accumulator)
    ctx.process_declarations()
    ctx.process_usages()
    return _filter_snippet_instructions(code)
