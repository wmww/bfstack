import logging

logger = logging.getLogger(__name__)

class SourceFile:
    def __init__(self, args):
        self._path = args.source_path
        logger.info('Loading ' + self._path)
        with open(self._path, "r") as f:
            self._contents = f.read()

    def path(self) -> str:
        return self._path

    def line_text(self, line: int) -> str:
        return self._contents.splitlines()[line - 1]

    def span(self):
        from span import Span
        return Span(self, 0, len(self._contents))

    def contents(self) -> str:
        return self._contents
