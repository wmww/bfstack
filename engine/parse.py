from instruction import Instruction
from assertion import Assertion, AssertionCell, LiteralAssertionCell, VariableAssertionCell
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

def _assertion_cell(text: str) -> AssertionCell:
    number_matches = re.findall('^[0-9]+$', text)
    if number_matches:
        return LiteralAssertionCell(int(text))
    ident_matches = re.findall('^[a-zA-Z_][a-zA-Z_0-9]*$', text)
    if ident_matches:
        return VariableAssertionCell(text)
    raise RuntimeError('Invalid assertion cell: "' + text + '"')

def _assertion(text: str) -> Assertion:
    cell_strs = text.split()
    cells: List[AssertionCell] = []
    offset_of_current = None
    for cell_str in cell_strs:
        if cell_str.startswith('`'):
            if offset_of_current is not None:
                raise RuntimeError('Assertion "' + text + '" has multiple current cells')
            offset_of_current = len(cells)
            cell_str = cell_str[1:]
        cell = _assertion_cell(cell_str)
        cells.append(cell)
    if offset_of_current is None:
        raise RuntimeError('Assertion "' + text + '" has no current cell')
    return Assertion(cells, offset_of_current)

def _line(line: str, number: int, args: Args) -> List[Instruction]:
    assert isinstance(line, str)
    line = line.strip()
    code = _code(line, number + 1, 0)
    if args.assertions and line.startswith('='):
        if code:
            raise RuntimeError('Brainfuck code in assertion line ' + str(number))
        return [_assertion(line[1:].strip())]
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
