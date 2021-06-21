from typing import List

class Io:
    def print(self, message: str):
        raise NotImplementedError()

    def push_output(self, value: int):
        raise NotImplementedError()

    def pull_input(self) -> int:
        raise NotImplementedError()

    def time_waiting_for_input(self) -> float:
        raise NotImplementedError()

