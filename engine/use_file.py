from instruction import Instruction
from errors import ParseError, MultiParseError, SingleParseError
from snippets import SnippetStart
from args import Args
from span import Span
from op import Op
from source_file import SourceFile
import parse

from typing import TYPE_CHECKING, List, Iterable, Set
import os

if TYPE_CHECKING:
    from span import Span
    from program import Program

class UseStatement(Instruction):
    def __init__(self, path: str, span: 'Span'):
        self._span = span
        self.path = path

    def run(self, program: 'Program'):
        assert False, 'UseStatement should not have been run'

    def loop_level_change(self) -> int:
        return 0

    def ends_assertion_block(self) -> bool:
        return False

    def span(self) -> 'Span':
        return self._span

def _apply_prefix(path: str, code: List[Instruction]) -> List[Instruction]:
    prefix = os.path.splitext(os.path.basename(path))[0]
    return list(map(
        lambda instr: instr.clone_with_prefix(prefix) if isinstance(instr, SnippetStart) else instr,
        code,
    ))

class _Expander:
    def __init__(self, args: Args, error_accumulator: List[ParseError]):
        # Paths of files we've already loaded (to prevent infinite recursion)
        self._paths: Set[str] = set()
        self._errors = error_accumulator
        self._args = args

    def expand_use(self, use: UseStatement) -> List[Instruction]:
        current_file_path = use.span().source_file().path()
        current_file_dir = os.path.dirname(current_file_path)
        used_file_path = os.path.join(current_file_dir, use.path)
        normalized_used_file_path = os.path.normpath(os.path.relpath(used_file_path))
        if normalized_used_file_path in self._paths:
            self._errors.append(SingleParseError(
                normalized_used_file_path + ' used recursively, this is not yet implemented',
                use.span()
            ))
            return []
        self._paths.add(normalized_used_file_path)
        try:
            source_file = SourceFile(normalized_used_file_path)
            code = parse.source(source_file, self._args, self._errors)
            code = self.expand(code)
            code = _apply_prefix(normalized_used_file_path, code)
            return code
        except (FileNotFoundError, NotADirectoryError):
            self._errors.append(SingleParseError(normalized_used_file_path + ' not found', use.span()))
            return []

    def expand(self, code: List[Instruction]) -> List[Instruction]:
        result = []
        has_hit_first_op = False
        header_comment_loop_depth = 0
        for instr in code:
            if isinstance(instr, UseStatement):
                if header_comment_loop_depth:
                    result += self.expand_use(instr)
                else:
                    self._errors.append(SingleParseError('Use outside of header comment', instr.span()))
            else:
                result.append(instr)
            if not has_hit_first_op or header_comment_loop_depth:
                if isinstance(instr, Op):
                    if instr == '[':
                        header_comment_loop_depth += 1
                    elif instr == ']':
                        header_comment_loop_depth -= 1
                    has_hit_first_op = True
        return result

def expand(code: List[Instruction], args: Args, error_accumulator: List[ParseError]) -> List[Instruction]:
    '''Returns the code list with use statements expanded into their files'''
    expander = _Expander(args, error_accumulator)
    return expander.expand(code)
