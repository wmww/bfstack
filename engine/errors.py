from typing import Sequence, Optional, TYPE_CHECKING

from colors import make_color, Color

if TYPE_CHECKING:
    from span import Span
    from tape import Tape

class FileLoadingError(Exception):
    def __init__(self, message: str):
        super().__init__(message)

class MultiError:
    def __init__(self, errors: Sequence[Exception]):
        assert errors, 'Empty error list'
        self.errors = errors

    def __str__(self) -> str:
        return '\n' + '\n\n'.join([str(err) for err in self.errors]) + '\n'

class ParseError(Exception):
    '''For when the program has syntax errors'''
    pass

class SingleParseError(ParseError):
    def __init__(self, msg: str, span: 'Span'):
        super().__init__(span.error_str() + make_color(Color.ERROR, msg))

class MultiParseError(MultiError, ParseError):
    pass

class RunError(Exception):
    '''An error with a span and tape'''
    def __init__(self, message: str):
        self.message = message
        self.tape: Optional[Tape] = None
        self.span: Optional[Span] = None

    def __str__(self) -> str:
        result = ''
        if self.span:
            result += self.span.error_str()
        if self.tape:
            result += 'Tape: ' + str(self.tape) + '\n'
        result += self.message
        return result

class ProgramError(RunError):
    '''For when the program fails'''
    pass

class TestError(ProgramError):
    '''For when an assertion or test fails'''
    pass

class OffEdgeOfTestTapeError(ProgramError):
    '''Spacial error when using a test tape that indicates the program has left the known range'''
    def __init__(self, tape: 'Tape'):
        super().__init__('')
        self.tape = tape

class MultiProgramError(MultiError, ProgramError):
    pass

class UnexpectedSuccessError(RunError):
    pass

class MultiUnexpectedSuccessError(MultiError, UnexpectedSuccessError):
    pass
