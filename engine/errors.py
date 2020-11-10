from span import Span

class ParseError(RuntimeError):
    '''For when the program has syntax errors'''
    def __init__(self, msg: str, span: Span):
        super().__init__(str(span) + ': ' + msg)
        self._span = span

    def span(self):
        return self._span

class ProgramError(RuntimeError):
    '''For when the program fails at runtime'''
    def set_span(self, span: Span):
        self._span = span
        assert self.args, str(self) + ' has no args'
        self.args = (span.error_str() + self.args[0],) + self.args[1:]

    def span(self):
        if hasattr(self, '_span'):
            return self._span
        else:
            return None

class TestError(ProgramError):
    '''For when an assertion or test fails'''
    pass

class TooFarLeftError(ProgramError):
    '''For when the pointer moves to the left of the start'''
    def __init__(self):
        super().__init__('Too far left')
