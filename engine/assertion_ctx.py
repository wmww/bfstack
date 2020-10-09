from random import Random

class AssertionCtx:
    def __init__(self):
        self.rand = Random(0) # Just use 0 seed for now

    def random_byte(self):
        return self.rand.randint(0, 255)
