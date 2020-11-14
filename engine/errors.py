from typing import Sequence, Optional, TYPE_CHECKING

if TYPE_CHECKING:
    from span import Span
    from tape import Tape

def _format_error_list(errors: Sequence[Exception]):
    assert errors, 'Empty error list'
    result = str(len(errors)) + ' error' + ('s' if len(errors) != 1 else '') + ':'
    for e in errors:
        result += '\n\n' + str(e)
    return result

class ParseError(Exception):
    '''For when the program has syntax errors'''
    pass

class SingleParseError(ParseError):
    def __init__(self, msg: str, span: 'Span'):
        super().__init__(span.error_str() + msg)

class MultiParseError(ParseError):
    def __init__(self, errors: Sequence[ParseError]):
        super().__init__(_format_error_list(errors))

class ProgramError(Exception):
    '''For when the program fails at runtime'''
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

class TestError(ProgramError):
    '''For when an assertion or test fails'''
    pass

class OffEdgeOfTestTapeError(ProgramError):
    '''Spacial error when using a test tape that indicates the program has left the known range'''
    def __init__(self, tape: 'Tape'):
        super().__init__('')
        self.tape = tape

class MultiProgramError(ProgramError):
    '''Bundles multiple errors together'''
    def __init__(self, errors: Sequence[ProgramError]):
        super().__init__('')
        self.errors = errors

    def __str__(self) -> str:
        return _format_error_list(self.errors)
