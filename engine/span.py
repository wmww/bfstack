from source_file import SourceFile
from op import op_set
from colors import make_color, Color

import os
from typing import Optional

class Span:
    def __init__(self, source: SourceFile, start_char: int, end_char: int):
        self._source = source
        self._start_char = start_char
        self._end_char = end_char

    def line(self) -> int:
        return self._source.line_of(self._start_char)

    def col(self) -> int:
        return self._source.col_of(self._start_char)

    def text(self) -> str:
        return self._source.contents()[self._start_char:self._end_char]

    def source_file(self) -> SourceFile:
        return self._source

    def length(self) -> int:
        return self._end_char - self._start_char

    def ops(self) -> str:
        return ''.join(c for c in self.text() if c in op_set)

    def sub_span(self, start_offset: int, end_offset: int) -> 'Span':
        assert start_offset >= 0, 'Invalid start offset ' + str(start_offset)
        start_char = self._start_char + start_offset
        if end_offset >= 0:
            end_char = self._start_char + end_offset
        else:
            end_char = self._end_char + end_offset
        assert end_char >= start_char, 'End offset ' + str(end_offset) + ' < start offset ' + str(start_offset)
        assert end_char <= self._end_char, (
            'End offset ' + str(end_offset) + ' > span length ' + str(self.length()))
        result = Span(self._source, start_char, end_char)
        #print('"' + self.text() + '"[' + str(start_offset) + ':' + str(end_offset) + '] -> "' + result.text() + '"')
        return result

    def __getitem__(self, val) -> 'Span':
        assert isinstance(val, slice), '__getitem__() called on Span with non-slice ' + str(type(val))
        start = val.start if val.start else 0
        stop = val.stop if val.stop else self._end_char - self._start_char
        assert val.step is None or val.step == 1, 'Invalid step ' + str(val.step)
        return self.sub_span(start, stop)

    def __str__(self) -> str:
        return (
            os.path.relpath(self._source.path()) + ':' + str(self.line()) + ' ' +
            str(self.col()) + '..' + str(self.col() + self.length() - 1))

    def error_file_path(self) -> str:
        return make_color(Color.FILEPATH, os.path.relpath(self._source.path()) + ':' + str(self.line()))

    def error_str(self) -> str:
        '''Format in a way suitable for error messages, ends with a newline'''
        result = self.error_file_path() + make_color(Color.FILEPATH, ':') + '\n'
        start_line = self._source.line_of(self._start_char)
        end_line = self._source.line_of(self._end_char)
        if start_line == end_line:
            result += self._source.line_text(self.line()) + '\n'
            if self.length() > 0:
                result += make_color(Color.ERROR, ' ' * (self.col() - 1) + '^' * self.length() + '\n')
            else:
                result += make_color(Color.ERROR, ' ' * (self.col() - 1) + '\_[zero-length span]' + '\n')
        else:
            max_right = 0
            for i in range(start_line, end_line + 1):
                text = self._source.line_text(i)
                max_right = max(max_right, len(text))
            start_col = self._source.col_of(self._start_char) - 1
            end_col = self._source.col_of(self._end_char) - 1
            result += ' ' * (start_col + 1)
            result += make_color(Color.ERROR, '_' * (max_right - start_col)) + '\n'
            for i in range(start_line, end_line + 1):
                text = self._source.line_text(i)
                result += ' ' if i == start_line else make_color(Color.ERROR, '|')
                result += text
                result += ' ' * (max_right - len(text))
                result += ' ' if i == end_line else make_color(Color.ERROR, '|')
                result += '\n'
            result += ' ' + make_color(Color.ERROR, '^' * end_col) + '\n'
        return result

    def extend_to(self, other: 'Span') -> 'Span':
        '''Combine two spans'''
        start = min(self._start_char, other._start_char)
        end = max(self._end_char, other._end_char)
        return Span(self._source, start, end)

    def strip(self) -> 'Span':
        '''Like str.strip(), strips whitespace'''
        text = self.text()
        start = self._start_char
        end = self._end_char
        while len(text) and text[-1].isspace():
            text = text[:-1]
            end -= 1
        while len(text) and text[0].isspace():
            text = text[1:]
            start += 1
        return Span(self._source, start, end)
