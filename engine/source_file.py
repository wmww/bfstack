from errors import FileLoadingError
from colors import make_color, Color

import logging
import os
from typing import Dict, Optional

logger = logging.getLogger(__name__)

class SourceFile:
    def __init__(self, path: str):
        self._path = path
        logger.info('Loading ' + self._path)
        try:
            with open(self._path, "r") as f:
                self._contents = f.read()
        except (FileNotFoundError, NotADirectoryError, PermissionError) as e:
            raise FileLoadingError(str(e))
        self._lines = self._contents.splitlines()
        self._used_files: Dict[str, SourceFile] = dict()

    def add_used_file(self, name: str, source: 'SourceFile'):
        if name in self._used_files:
            raise FileLoadingError(name + ' used multiple times')
        self._used_files[name] = source

    def get_used_file(self, name: str) -> 'Optional[SourceFile]':
        return self._used_files.get(name)

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
