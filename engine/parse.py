from instruction import Instruction
from snippets import SnippetInstr, SnippetStart, SnippetEnd
from use_file import UseStatement
from assertion import TapeAssertion, AssertionReset, StartTapeAssertion, TestInput, Matcher, LiteralMatcher, VariableMatcher, WildcardMatcher, InverseMatcher
from op import Op, op_set
from source_file import SourceFile
from span import Span
from args import Args
from errors import ParseError, MultiParseError, SingleParseError

import re
from typing import List, Set

snippet_name = re.compile(r'[a-zA-Z_][a-zA-Z_:0-9]*$')
var_name = re.compile(r'^[a-zA-Z_][a-zA-Z_0-9]*$')
number = re.compile(r'^[0-9]+$')
use_statement = re.compile(r'^use\s"(.*)"$')

def _code_and_snippets(span: Span, args: Args) -> List[Instruction]:
    code: List[Instruction] = []
    text = span.text()
    for i, c in enumerate(text):
        if c in op_set:
            code.append(Op(c, span[i:i+1]))
        elif args.snippets:
            if c == '{':
                name_match = snippet_name.search(text[:i])
                if name_match is None:
                    raise SingleParseError('Snippet without name', span[i:i+1])
                name = name_match.group(0)
                name_components = name.split('::')
                name_span = span[i-len(name):i+1]
                for component in name_components:
                    if ':' in component:
                        raise SingleParseError('Snippet name contains stray ":"', name_span)
                code.append(SnippetStart(name_components, name_span))
            elif c == '}':
                code.append(SnippetEnd(span[i:i+1]))
    return code

whitespace = set([' ', '\t', '\n'])

def _matcher(span: Span) -> Matcher:
    text = span.text()
    if text.startswith('!'):
        return InverseMatcher(_matcher(span[1:]))
    if text == '*':
        return WildcardMatcher()
    number_matches = number.findall(text)
    if number_matches:
        value = int(text)
        if value < 0 or value >= 256:
            raise SingleParseError('Invalid cell value ' + str(value) + ', must be in range 0-255', span)
        return LiteralMatcher(text, int(text))
    ident_matches = var_name.findall(text)
    if ident_matches:
        return VariableMatcher(text)
    raise SingleParseError('Invalid assertion cell: "' + text + '"', span)

def _split_on(span: Span, split: Set[str]) -> List[Span]:
    start = 0
    result: List[Span] = []
    for i, c in enumerate(span.text() + list(split)[0]):
        if c in split:
            if i > start:
                result.append(span[start:i])
            start = i + 1
    return result

def _tape_assertion(span: Span) -> Instruction:
    cell_spans = _split_on(span, whitespace)[1:]
    cells: List[Matcher] = []
    offset_of_current = None
    slide_left = False
    slide_right = False
    for i, cell_span in enumerate(cell_spans):
        text = cell_span.text()
        if text == '~':
            if i == 0:
                slide_left = True
            elif i == len(cell_spans) - 1:
                slide_right = True
            else:
                raise SingleParseError('"~" not allowed anywhere but the start and end', cell_span)
        elif text == '|':
            pass;
        else:
            if text.startswith('`'):
                if offset_of_current is not None:
                    raise SingleParseError('Assertion has multiple current cells', span)
                offset_of_current = len(cells)
                cell_span = cell_span[1:]
            cell = _matcher(cell_span)
            cells.append(cell)
    if slide_left and len(cell_spans) == 1:
        return AssertionReset(span)
    elif offset_of_current is None:
        raise SingleParseError('Assertion has no current cell', span)
    else:
        return TapeAssertion(cells, slide_left, slide_right, offset_of_current, span)

def _test_input(span: Span) -> TestInput:
    matcher_spans = _split_on(span, whitespace)
    matchers: List[Matcher] = []
    for matcher_span in matcher_spans[1:]:
        matchers.append(_matcher(matcher_span))
    return TestInput(matchers, span)

def _line(span: Span, args: Args) -> List[Instruction]:
    span = span.strip()
    text = span.text()
    if not text:
        return []
    code = _code_and_snippets(span, args)
    if args.snippets and text.startswith('use '):
        match = use_statement.match(text)
        if match is None:
            raise SingleParseError('Invalid use statement', span)
        else:
            return [UseStatement(match.group(1), span)]
    elif args.assertions and text[0] in ('=', '$'):
        if code:
            raise SingleParseError('Brainfuck code in assertion line', span)
        if text[0] == '=':
            return [_tape_assertion(span)]
        elif text[0] == '$':
            return [_test_input(span)]
        else:
            assert False, 'unreachable'
    else:
        return code

def _check_loops(code: List[Instruction], error_accumulator: List[ParseError]):
    loops = []
    for instr in code:
        if instr.loop_level_change() == 1:
            loops.append(instr)
        elif instr.loop_level_change() == -1:
            if len(loops):
                loops.pop(-1)
            else:
                error_accumulator.append(SingleParseError('Unmatched "]"', instr.span()))
        elif instr.loop_level_change() != 0:
            assert False, 'Invalid value ' + str(instr.loop_level_change()) + ' for loop level change'
    for instr in loops:
        error_accumulator.append(SingleParseError('Unmatched "["', instr.span()))

def source(
    source_file: SourceFile,
    args: Args,
    error_accumulator: List[ParseError]
) -> List[Instruction]:
    span = source_file.span()
    code: List[Instruction] = []
    if args.assertions:
        # An assertion at the start makes the property tests happy
        code.append(StartTapeAssertion(Span(source_file, 0, 0)))
    for sub in _split_on(span, set(['\n'])):
        try:
            code += _line(sub, args)
        except ParseError as err:
            error_accumulator.append(err)
    _check_loops(code, error_accumulator)
    return code
