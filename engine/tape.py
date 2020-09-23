from typing import List

class TooFarLeftError(RuntimeError):
    def __init__(self):
        super().__init__('Too far left')

class Tape:
    def __init__(self, position: int, data: List[int]):
        assert position >= 0
        self._position = position
        self._data = data

    def __str__(self):
        result = []
        for i, cell in enumerate(self._data):
            if i == self._position:
                result.append('`' + str(cell))
            else:
                result.append(str(cell))
        return ' '.join(result)

    def get_position(self) -> int:
        return self._position

    def get_value_relative(self, offset: int) -> int:
        i = self._position + offset
        if i < 0:
            raise TooFarLeftError()
        elif i >= len(self._data):
            return 0
        else:
            return self._data[i]

    def set_value_relative(self, offset: int, value: int):
        value = value % 256
        i = self._position + offset
        if i < 0:
            raise TooFarLeftError()
        while i >= len(self._data):
            self._data.append(0)
        self._data[i] = value

    def increment_by(self, value: int):
        self.set_value_relative(0, self.get_value_relative(0) + value)

    def move_by(self, delta: int):
        if -delta > self._position:
            raise TooFarLeftError()
        self._position += delta
