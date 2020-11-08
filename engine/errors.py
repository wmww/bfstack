class ParseError(RuntimeError):
    '''For when the program has syntax errors'''
    pass

class ProgramError(RuntimeError):
    '''For when the program fails at runtime'''
    pass

class TestError(ProgramError):
    '''For when an assertion or test fails'''
    pass

class TooFarLeftError(ProgramError):
    '''For when the pointer moves to the left of the start'''
    def __init__(self):
        super().__init__('Too far left')
