import assertion
import engine
import args

import re
from typing import List

def _code(text: str, line: int, offset: int):
    code = []
    for i, c in enumerate(text):
        if c in engine.ops:
            code.append(engine.Instruction(line, i + offset + 1, c))
    if code:
        return engine.Code(code)
    else:
        return None

def _assertion_cell(text: str) -> assertion.Cell:
    current = False
    if text.startswith('`'):
        current = True
        text = text[1:]
    if not text:
        raise RuntimeError('Empty cell')
    number_matches = re.findall('^[0-9]+$', text)
    if number_matches:
        return assertion.Cell(current, int(text))
    ident_matches = re.findall('^[a-zA-Z_][a-zA-Z_0-9]*$', text)
    if ident_matches:
        return assertion.Cell(current, text)
    raise RuntimeError('Invalid assertion cell: ' + text)

def _assertion(text: str) -> assertion.State:
    cell_strs = text.split()
    cells = []
    for cell_str in cell_strs:
        cell = _assertion_cell(cell_str)
        cells.append(cell)
    return assertion.State(cells)

def _line(line: str, number: int):
    '''Returns engine.Code, assertion.State, None or raises a RuntimeError'''
    assert isinstance(line, str)
    line = line.strip()
    if line.startswith('='):
        return _assertion(line[1:].strip())
    else:
        return _code(line, number + 1, 0)

def source_file(source_file: args.SourceFile) -> List:
    sections: List = []
    errors = []
    for i, line in enumerate(source_file.contents().splitlines()):
        try:
            parsed = _line(line, i)
            if parsed:
                if sections and isinstance(parsed, engine.Code) and isinstance(sections[-1], engine.Code):
                    sections[-1].code += parsed.code
                else:
                    sections.append(parsed)
        except RuntimeError as err:
            errors.append(str(source_file) + ':' + str(i) + ': ' + str(err))
    if errors:
        message = str(len(errors)) + ' error' + ('s' if len(errors) > 1 else '') + ':'
        message += ''.join('\n\n' + error for error in errors)
        raise RuntimeError(message)
    return sections
