from random import Random
from typing import Dict, Set
from io_interface import Io

class AssertionCtx:
    def __init__(self, seed):
        self.rand = Random(seed)
        self.bound_vars: Dict[str, int] = {}

    def random_biased_byte(self) -> int:
        value = self.rand.randint(0, 256 * 3)
        # Most commonly returns 0, then 1 or 255, then anything
        if value >= 256 * 2:
            return 0
        elif value > 256 * 1.5:
            return 1
        elif value >= 256:
            return 255
        else:
            return value

    def remove_unused_vars(self, used_vars: Set[str]):
        to_remove = []
        for name, value in self.bound_vars.items():
            if name not in used_vars:
                to_remove.append(name)
        for name in to_remove:
            del self.bound_vars[name]

class AssertionCtxIo(Io):
    def __init__(self, ctx: AssertionCtx):
        self.ctx = ctx

    def push_output(self, value: int):
        pass

    def pull_input(self) -> int:
        return self.ctx.random_biased_byte()

    def time_waiting_for_input(self) -> float:
        return 0.0
