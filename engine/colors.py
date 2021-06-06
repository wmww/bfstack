import sys, os

use_color = (os.name == 'posix' and hasattr(sys.stdout, 'isatty') and sys.stdout.isatty())

class Color:
    ERROR = '1;31'
    GOOD = '1;32'
    FILEPATH = '35'
    TAPE = '36'
    INFO = '1;34'

def make_color(color: str, text: str) -> str:
    if use_color:
        return '\x1b[' + color + 'm' + text + '\x1b[0m'
    else:
        return text
