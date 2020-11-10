from random import Random
from typing import Dict, Set

class AssertionCtx:
    def __init__(self, seed):
        self.rand = Random(seed)
        self.bound_vars: Dict[str, int] = {}

    def random_byte(self):
        return self.rand.randint(0, 255)

    def remove_unused_vars(self, used_vars: Set[str]):
        to_remove = []
        for name, value in self.bound_vars.items():
            if name not in used_vars:
                to_remove.append(name)
        for name in to_remove:
            del self.bound_vars[name]
