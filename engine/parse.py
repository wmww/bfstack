from instruction import Instruction
from assertion import TapeAssertion, TestInput, Matcher, LiteralMatcher, VariableMatcher, WildcardMatcher, InverseMatcher
from op import Op, op_set
from source_file import SourceFile
from args import Args
import optimize

import re
from typing import List

def _code(text: str, line: int, offset: int) -> List[Instruction]:
    code: List[Instruction] = []
    for i, c in enumerate(text):
        if c in op_set:
            code.append(Op(line, i + offset + 1, c))
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

def _character_literal(text: str) -> int:
    if text.startswith('\\'):
        if len(text) != 2 or text[1] not in escapes:
            raise RuntimeError('Invalid escape sequence: "' + text + '"')
        return ord(escapes[text[1]])
    else:
        if len(text) > 1:
            raise RuntimeError('Invalid character literal: "' + text + '"')
        return ord(text)

def _matcher(text: str) -> Matcher:
    if text.startswith('!'):
        return InverseMatcher(_matcher(text[1:]))
    if text == '*':
        return WildcardMatcher()
    if text.startswith('@'):
        return LiteralMatcher(text, _character_literal(text[1:]))
    number_matches = re.findall('^[0-9]+$', text)
    if number_matches:
        return LiteralMatcher(text, int(text))
    ident_matches = re.findall('^[a-zA-Z_][a-zA-Z_0-9]*$', text)
    if ident_matches:
        return VariableMatcher(text)
    raise RuntimeError('Invalid assertion cell: "' + text + '"')

def _tape_assertion(text: str) -> TapeAssertion:
    cell_strs = text.split()
    cells: List[Matcher] = []
    offset_of_current = None
    for cell_str in cell_strs:
        if cell_str.startswith('`'):
            if offset_of_current is not None:
                raise RuntimeError('Assertion "' + text + '" has multiple current cells')
            offset_of_current = len(cells)
            cell_str = cell_str[1:]
        cell = _matcher(cell_str)
        cells.append(cell)
    if offset_of_current is None:
        raise RuntimeError('Assertion "' + text + '" has no current cell')
    return TapeAssertion(cells, offset_of_current)

def _test_input(text: str) -> TestInput:
    matcher_strs = text.split()
    matchers: List[Matcher] = []
    for matcher_str in matcher_strs:
        matchers.append(_matcher(matcher_str))
    return TestInput(matchers)

def _line(line: str, number: int, args: Args) -> List[Instruction]:
    line = line.strip()
    if not line:
        return []
    code = _code(line, number + 1, 0)
    if args.assertions and line[0] in ('=', '$'):
        if code:
            raise RuntimeError('Brainfuck code in assertion line ' + str(number))
        if line[0] == '=':
            return [_tape_assertion(line[1:].strip())]
        elif line[0] == '$':
            return [_test_input(line[1:].strip())]
        else:
            assert False, 'unreachable'
    else:
        return code

def source(source_file: SourceFile, args: Args) -> List[Instruction]:
    code: List[Instruction] = []
    errors = []
    for i, line in enumerate(source_file.contents().splitlines()):
        try:
            code += _line(line, i, args)
        except RuntimeError as err:
            errors.append(str(source_file) + ':' + str(i) + ': ' + str(err))
    # TODO: notice unmatched braces here
    if errors:
        message = str(len(errors)) + ' error' + ('s' if len(errors) > 1 else '') + ':'
        message += ''.join('\n\n' + error for error in errors)
        raise RuntimeError(message)
    if args.optimize:
        optimize.optimize(code)
    return code
