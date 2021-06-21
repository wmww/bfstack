from io_interface import Io

from typing import List
import sys
import time

class UserIo(Io):
    def __init__(self) -> None:
        self.input_time: float = 0.0
        self.input_buffer: List[int] = []
        if sys.stdin.isatty():
            self.input_prompt = 'input: '
        else:
            self.input_prompt = ''

    def push_output(self, value: int):
        print(chr(value), end='', flush=True)

    def pull_input(self) -> int:
        if not self.input_buffer:
            start_time = time.time()
            try:
                self.input_buffer = list(map(ord, list(input(self.input_prompt)) + ['\n']))
            except EOFError:
                self.input_buffer = [0]
            end_time = time.time()
            self.input_time += end_time - start_time
        return self.input_buffer.pop(0)

    def queue_input(self, values: List[int]):
        pass

    def time_waiting_for_input(self) -> float:
        return self.input_time

    def reset(self):
        pass
