from source_file import SourceFile

from typing import Optional

class Span:
    def __init__(self, source: SourceFile, start_char: int, end_char: int):
        self._source = source
        self._start_char = start_char
        self._end_char = end_char
        self._cached_line: Optional[int] = None
        self._cached_col: Optional[int] = None

    def line(self) -> int:
        if self._cached_line is None:
            self._cached_line = 1
            for c in self._source.contents()[:self._start_char]:
                if c == '\n':
                    self._cached_line += 1
        return self._cached_line

    def col(self) -> int:
        if self._cached_col is None:
            self._cached_col = 1
            for c in self._source.contents()[:self._start_char:-1]:
                if c == '\n':
                    break
                self._cached_col += 1
        return self._cached_col

    def text(self) -> str:
        return self._source.contents()[self._start_char:self._end_char]

    def length(self) -> int:
        return self._end_char - self._start_char

    def sub_span(self, start_offset: int, end_offset: int):
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

    def __getitem__(self, val):
        if isinstance(val, slice):
            start = val.start if val.start else 0
            stop = val.stop if val.stop else self._end_char - self._start_char
            assert val.step is None or val.step == 1, 'Invalid step ' + str(val.step)
            return self.sub_span(start, stop)

    def __str__(self):
        return self._source.path() + ':' + str(self.line()) + ':' + str(self.col())

    def error_str(self) -> str:
        result = self._source.path() + ':' + str(self.line()) + ':\n'
        result += self._source.line_text(self.line()) + '\n'
        result += ' ' * (self.col() - 1) + '^' * self.length()
        return result

    def extend_to(self, other):
        self._start_char = min(self._start_char, other._start_char)
        self._end_char = max(self._end_char, other._end_char)
