import logging

logger = logging.getLogger(__name__)

class SourceFile:
    def __init__(self, path):
        logger.info('Loading ' + path)
        f = open(path, "r")
        self._path = path
        self._contents = f.read()
        f.close()

    def path(self):
        return self._path

    def contents(self):
        return self._contents
