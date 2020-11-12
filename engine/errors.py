from span import Span

from typing import Sequence

def _format_error_list(errors: Sequence[Exception]):
    assert errors, 'Empty error list'
    result = str(len(errors)) + ' error' + ('s' if len(errors) != 1 else '') + ':'
    for e in errors:
        result += '\n\n' + str(e)
    return result

class ParseError(RuntimeError):
    '''For when the program has syntax errors'''
    pass

class SingleParseError(ParseError):
    def __init__(self, msg: str, span: Span):
        super().__init__(span.error_str() + msg)

class MultiParseError(ParseError):
    def __init__(self, errors: Sequence[ParseError]):
        super().__init__(_format_error_list(errors))

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

class MultiProgramError(ProgramError):
    '''Bundles multiple errors together'''
    def __init__(self, errors: Sequence[ProgramError]):
        super().__init__(_format_error_list(errors))
