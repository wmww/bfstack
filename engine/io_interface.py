from typing import List

class Io:
    def push_output(self, value: int):
        raise NotImplementedError()

    def pull_input(self) -> int:
        raise NotImplementedError()

    def queue_input(self, value: List[int]):
        raise NotImplementedError()
