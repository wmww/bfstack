from random import Random
from typing import Dict, Set

class AssertionCtx:
    def __init__(self):
        self.rand = Random(0) # Just use 0 seed for now
        self.bound_vars: Dict[str, int] = {}
        self.used_vars: Set[str] = set()

    def random_byte(self):
        return self.rand.randint(0, 255)

    def remove_unused_vars(self):
        to_remove = []
        for name, value in self.bound_vars.items():
            if name not in self.used_vars:
                to_remove.append(name)
        for name in to_remove:
            del self.bound_vars[name]
        self.used_vars = set()
