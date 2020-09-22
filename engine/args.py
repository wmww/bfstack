import logging

logger = logging.getLogger(__name__)

class Args:
    def __init__(self, argv):
        args = argv[1:]
        if len(args) == 1:
            self._source_file = args[0]
        elif len(args) == 0:
            raise RuntimeError('No source file specified')
        else:
            raise RuntimeError('Too many arguments')

    def load_source_file(self):
        return SourceFile(self._source_file)

class SourceFile:
    def __init__(self, path):
        logger.info('Loading ' + path)
        f = open(path, "r")
        self._contents = f.read()
        f.close()

    def contents(self):
        return self._contents
