from instruction import Instruction
from errors import ParseError, SingleParseError, FileLoadingError
from args import Args
from span import Span
from program import Program
from op import Op
from source_file import SourceFile
import split_header
import parse

from typing import List, Dict, Tuple
import os

class UseStatement(Instruction):
    def __init__(self, path: str, span: 'Span'):
        self._span = span
        self._path = path

    def path(self) -> str:
        return self._path

    def prefix(self) -> str:
        '''name of used file without the extension'''
        return os.path.splitext(os.path.basename(self._path))[0]

    def run(self, program: 'Program'):
        assert False, 'UseStatement should not have been run'

    def loop_level_change(self) -> int:
        return 0

    def ends_assertion_block(self) -> bool:
        return False

    def span(self) -> 'Span':
        return self._span

def _canonical_path(path: str) -> str:
    return os.path.realpath(os.path.abspath(path))

class _Ctx:
    def __init__(self, args: Args, error_accumulator: List[ParseError]):
        self._files: Dict[str, SourceFile] = dict()
        self.args = args
        self.errors = error_accumulator

    def load_source(self, path: str) -> Tuple[bool, SourceFile]:
        '''Returns is_new, source'''
        canonical_path = _canonical_path(path)
        if canonical_path in self._files:
            return False, self._files[canonical_path]
        else:
            source = SourceFile(path, True)
            self._files[canonical_path] = source
            return True, source

def _expand_use(instr: UseStatement, ctx: _Ctx) -> List[Instruction]:
    try:
        path = os.path.join(os.path.dirname(instr.span().source_file().path()), instr.path())
        is_new, source = ctx.load_source(path)
        instr.span().source_file().add_used_file(instr.prefix(), source)
        if is_new:
            used_code = parse.source(source, ctx.args, ctx.errors)
            used_header, used_body = split_header.split_header(used_code)
            return _expand_header(used_header, ctx) + used_body
        else:
            return []
    except FileLoadingError as e:
        ctx.errors.append(SingleParseError(str(e), instr.span()))
        return [instr]

def _expand_header(header: List[Instruction], ctx: _Ctx) -> List[Instruction]:
    result = []
    for instr in header:
        if isinstance(instr, UseStatement):
            result += _expand_use(instr, ctx)
        else:
            result.append(instr)
    return result

def _check_body_for_erroneous_use_statements(body: List[Instruction], ctx: _Ctx):
    for instr in body:
        if isinstance(instr, UseStatement):
            ctx.errors.append(SingleParseError('Use outside of header comment', instr.span()))

def expand(code: List[Instruction], args: Args, error_accumulator: List[ParseError]) -> List[Instruction]:
    '''Returns the code list with use statements expanded into their files'''
    ctx = _Ctx(args, error_accumulator)
    header, body = split_header.split_header(code)
    header = _expand_header(header, ctx)
    _check_body_for_erroneous_use_statements(body, ctx) # does not return anything
    return header + body
