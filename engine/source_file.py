from errors import ParseError
from colors import make_color, Color

import logging

logger = logging.getLogger(__name__)

class SourceFile:
    def __init__(self, path: str):
        self._path = path
        logger.info('Loading ' + self._path)
        try:
            with open(self._path, "r") as f:
                self._contents = f.read()
        except FileNotFoundError:
            raise ParseError('File not found: ' + make_color(Color.ERROR, path))
        self._lines = self._contents.splitlines()

    def path(self) -> str:
        return self._path

    def line_text(self, line: int) -> str:
        return self._lines[line - 1]

    def line_of(self, char: int) -> int:
        for i, line in enumerate(self._lines):
            # -1 is for lost newline at end
            char = char - len(line) - 1
            if char < 0:
                # i + 1 because lines start at 1
                return i + 1
        return len(self._lines)

    def col_of(self, char: int) -> int:
        for i, line in enumerate(self._lines):
            # -1 is for lost newline at end
            char = char - len(line) - 1
            if char < 0:
                # + 2 because cols start at 1 and previous - 1
                return char + len(line) + 2
        return 0

    def span(self):
        from span import Span
        return Span(self, 0, len(self._contents))

    def contents(self) -> str:
        return self._contents
