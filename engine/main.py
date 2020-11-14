#!/usr/bin/python3

from args import Args
from errors import ProgramError, ParseError
from io_interface import Io
from run import run

import sys
import time
import logging
from typing import List

logger = logging.getLogger(__name__)

class UserIo(Io):
    def __init__(self) -> None:
        self.input_time: float = 0.0
        self.input_buffer: List[str] = []

    def push_output(self, value: int):
        print(chr(value), end='')

    def pull_input(self) -> int:
        if not self.input_buffer:
            start_time = time.time()
            self.input_buffer = list(input('input: ')) + ['\n']
            end_time = time.time()
            self.input_time += end_time - start_time
        return ord(self.input_buffer.pop(0))

    def queue_input(self, values: List[int]):
        pass

    def time_waiting_for_input(self) -> float:
        return self.input_time

    def reset(self):
        pass

def main() -> None:
    args = Args()
    args.parse(sys.argv[1:]) # strip off the first argument (program name)
    if args.show_info:
        logging.basicConfig(level=logging.INFO)
    success = False
    try:
        io = UserIo()
        run(args, io)
        success = True
    except FileNotFoundError as e:
        logger.error(e)
    except ParseError as e:
        logger.error('Syntax error: ' + str(e))
    except ProgramError as e:
        logger.error('Program failed: ' + str(e))
    if not success:
        exit(1)

if __name__ == '__main__':
    main();
