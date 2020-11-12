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
    def set_context(self, span: Span, tape):
        if self.span() is None:
            self._span = span
        result = ''
        assert self.args, str(self) + ' has no args'
        if self._span:
            result += self._span.error_str()
        if tape:
            result += 'Tape: ' + str(tape) + '\n'
        if result:
            self.args = (result + self.args[0],) + self.args[1:]

    def span(self):
        if hasattr(self, '_span'):
            return self._span
        else:
            return None

class TestError(ProgramError):
    '''For when an assertion or test fails'''
    pass

class OffEdgeOfTestTapeError(ProgramError):
    '''Spacial error when using a test tape that indicates the program has left the known range'''
    pass

class MultiProgramError(ProgramError):
    '''Bundles multiple errors together'''
    def __init__(self, errors: Sequence[ProgramError]):
        super().__init__(_format_error_list(errors))
