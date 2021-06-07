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

def _code_and_snippets(span: Span, args: Args, error_accumulator: List[ParseError]) -> List[Instruction]:
    code: List[Instruction] = []
    text = span.text()
    for i, c in enumerate(text):
        if c in op_set:
            code.append(Op(c, span[i:i+1]))
        elif args.snippets:
            if c == '{':
                name_match = snippet_name.search(text[:i])
                if name_match is None:
                    bracket_span = span[i:i+1]
                    error_accumulator.append(SingleParseError('Snippet without name', bracket_span))
                    code.append(SnippetStart([SnippetStart.UNNAMED_SNIPPET_NAME], bracket_span))
                else:
                    name = name_match.group(0)
                    name_components = name.split('::')
                    name_span = span[i-len(name):i+1]
                    for component in name_components:
                        if ':' in component:
                            error_accumulator.append(SingleParseError('Snippet name contains stray ":"', name_span))
                    code.append(SnippetStart(name_components, name_span))
            elif c == '}':
                code.append(SnippetEnd(span[i:i+1]))
    return code

whitespace = set([' ', '\t', '\n'])

def _matcher(span: Span, error_accumulator: List[ParseError]) -> Matcher:
    text = span.text()
    if text.startswith('!'):
        return InverseMatcher(_matcher(span[1:], error_accumulator))
    if text == '*':
        return WildcardMatcher()
    number_matches = number.findall(text)
    if number_matches:
        value = int(text)
        if value < 0 or value >= 256:
            error_accumulator.append(SingleParseError(
                'Invalid cell value ' + str(value) + ', must be in range 0-255',
                span,
            ))
            return WildcardMatcher()
        else:
            return LiteralMatcher(text, int(text))
    ident_matches = var_name.findall(text)
    if ident_matches:
        return VariableMatcher(text)
    else:
        error_accumulator.append(SingleParseError('Invalid assertion cell: "' + text + '"', span))
        return WildcardMatcher();

def _split_on(span: Span, split: Set[str]) -> List[Span]:
    start = 0
    result: List[Span] = []
    for i, c in enumerate(span.text() + list(split)[0]):
        if c in split:
            if i > start:
                result.append(span[start:i])
            start = i + 1
    return result

def _tape_assertion(span: Span, error_accumulator: List[ParseError]) -> Instruction:
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
                error_accumulator.append(SingleParseError('"~" not allowed anywhere but the start and end', cell_span))
        elif text == '|':
            pass;
        else:
            if text.startswith('`'):
                if offset_of_current is None:
                    offset_of_current = len(cells)
                else:
                    error_accumulator.append(SingleParseError('Assertion has multiple current cells', span))
                cell_span = cell_span[1:]
            cell = _matcher(cell_span, error_accumulator)
            cells.append(cell)
    if slide_left and len(cell_spans) == 1:
        return AssertionReset(span)
    elif offset_of_current is None:
        error_accumulator.append(SingleParseError('Assertion has no current cell', span))
        return AssertionReset(span)
    else:
        return TapeAssertion(cells, slide_left, slide_right, offset_of_current, span)

def _test_input(span: Span, error_accumulator: List[ParseError]) -> TestInput:
    matcher_spans = _split_on(span, whitespace)
    matchers: List[Matcher] = []
    for matcher_span in matcher_spans[1:]:
        matchers.append(_matcher(matcher_span, error_accumulator))
    return TestInput(matchers, span)

def _line(span: Span, args: Args, error_accumulator: List[ParseError]) -> List[Instruction]:
    span = span.strip()
    text = span.text()
    if not text:
        return []
    code = _code_and_snippets(span, args, error_accumulator)
    if args.snippets and text.startswith('use '):
        match = use_statement.match(text)
        if match is None:
            error_accumulator.append(SingleParseError('Invalid use statement', span))
            return code
        else:
            return [UseStatement(match.group(1), span)]
    elif args.assertions and text[0] in ('=', '$'):
        if code:
            error_accumulator.append(SingleParseError('Brainfuck code in assertion line', span))
            return code
        if text[0] == '=':
            return [_tape_assertion(span, error_accumulator)]
        elif text[0] == '$':
            return [_test_input(span, error_accumulator)]
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
        code += _line(sub, args, error_accumulator)
    _check_loops(code, error_accumulator)
    return code
