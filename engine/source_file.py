import logging

logger = logging.getLogger(__name__)

class SourceFile:
    def __init__(self, args):
        self._path = args.source_path
        logger.info('Loading ' + self._path)
        with open(self._path, "r") as f:
            self._contents = f.read()

    def path(self):
        return self._path

    def contents(self):
        return self._contents
