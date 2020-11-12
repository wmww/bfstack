from instruction import Instruction
from assertion import TapeAssertion, EmptyTapeAssertion, StartTapeAssertion, TestInput, Matcher, LiteralMatcher, VariableMatcher, WildcardMatcher, InverseMatcher
from op import Op, op_set
from source_file import SourceFile
from span import Span
from args import Args
import optimize
from errors import ParseError, MultiParseError, SingleParseError

import re
from typing import List, Set

def _code(span: Span) -> List[Instruction]:
    code: List[Instruction] = []
    for i, c in enumerate(span.text()):
        if c in op_set:
            code.append(Op(c, span[i:i+1]))
    return code

escapes = {
    'n': '\n',
    't': '\t',
    's': ' ',
    '\\': '\\',
    ':': '.',
    ';': ',',
    '#': '+',
    '~': '-',
    '{': '<',
    '}': '>',
    '(': '[',
    ')': ']',
}

whitespace = set([' ', '\t', '\n'])

def _character_literal(span: Span) -> int:
    text = span.text()
    if text.startswith('\\'):
        if len(text) != 2 or text[1] not in escapes:
            raise SingleParseError('Invalid escape sequence: "' + text + '"', span)
        return ord(escapes[text[1]])
    else:
        if len(text) > 1:
            raise SingleParseError('Invalid character literal: "' + text + '"', span)
        return ord(text)

def _matcher(span: Span) -> Matcher:
    text = span.text()
    if text.startswith('!'):
        return InverseMatcher(_matcher(span[1:]))
    if text == '*':
        return WildcardMatcher()
    if text.startswith('@'):
        return LiteralMatcher(text, _character_literal(span[1:]))
    number_matches = re.findall('^[0-9]+$', text)
    if number_matches:
        return LiteralMatcher(text, int(text))
    ident_matches = re.findall('^[a-zA-Z_][a-zA-Z_0-9]*$', text)
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

def _tape_assertion(span: Span) -> TapeAssertion:
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
        else:
            if text.startswith('`'):
                if offset_of_current is not None:
                    raise SingleParseError('Assertion has multiple current cells', span)
                offset_of_current = len(cells)
                cell_span = cell_span[1:]
            cell = _matcher(cell_span)
            cells.append(cell)
    if slide_left and len(cell_spans) == 1:
        return EmptyTapeAssertion(span)
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
    code = _code(span)
    if args.assertions and text[0] in ('=', '$'):
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

def source(source_file: SourceFile, args: Args) -> List[Instruction]:
    code: List[Instruction] = []
    errors: List[ParseError] = []
    span = source_file.span()
    if args.assertions:
        # An assertion at the start makes the property tests happy
        code.append(StartTapeAssertion(Span(source_file, 0, 0)))
    for sub in _split_on(span, set(['\n'])):
        try:
            code += _line(sub, args)
        except ParseError as err:
            errors.append(err)
    loops = []
    for instr in code:
        if instr.loop_level_change() == 1:
            loops.append(instr)
        elif instr.loop_level_change() == -1:
            if len(loops):
                loops.pop(-1)
            else:
                errors.append(SingleParseError('Unmatched "]"', instr.span()))
        elif instr.loop_level_change() != 0:
            assert False, 'Invalid value ' + str(instr.loop_level_change()) + ' for loop level change'
    for instr in loops:
        errors.append(SingleParseError('Unmatched "["', instr.span()))
    if errors:
        raise MultiParseError(errors)
    if args.optimize:
        optimize.optimize(code)
    return code
