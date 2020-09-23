import logging

logger = logging.getLogger(__name__)

class Args:
    def __init__(self, argv):
        args = argv[1:]
        if len(args) == 1:
            self._source_path = args[0]
        elif len(args) == 0:
            raise RuntimeError('No source file specified')
        else:
            raise RuntimeError('Too many arguments')

    def source_path(self):
        return self._source_path

